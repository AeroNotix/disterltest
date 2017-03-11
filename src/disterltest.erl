-module(disterltest).

-behaviour(gen_server).

-export([send_message/1]).
-export([code_change/3]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([init/1]).
-export([start_link/0]).
-export([terminate/2]).
-export([world/0]).

-record(state, { interval :: non_neg_integer() }).

-include_lib("kernel/src/inet_dns.hrl").


send_message(Msg) ->
    gen_server:call(?MODULE, {route, Msg}).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    Interval = application:get_env(disterltest, world_interval, 5000),
    self() ! world,
    {ok, #state{ interval = Interval }}.

handle_call({route, Msg}, _From, State) ->
    [rpc:call(Node, io, format, ["Received meshed network: ~p~n", Msg])
     || Node <- nodes()],
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {stop, unknown_cast, State}.

handle_info(world, State) ->
    Interval = State#state.interval,
    try
        world()
    catch
        E:R ->
            lager:error("Error connecting to world: ~p", [{E,R}])
    after
        schedule_check(Interval)
    end,
    {noreply, State};
handle_info(_, State) ->
    {stop, unknown_info, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

world() ->
    try
        CName = application:get_env(disterltest, cluster_cname, "disterltest.default.svc.cluster.local"),
        {ok, Msg} = inet_res:nslookup(CName, in, a),
        ExtractedHosts = extract_hosts(Msg),
        [net_kernel:connect(Host) || Host <- ExtractedHosts],
        lager:error("~p~n", [nodes()]),
        ok
    catch
        E:R ->
            lager:error("Error looking up hosts: ~p", [{E, R, erlang:get_stacktrace()}]),
            timer:sleep(5000),
            world()
    end.

schedule_check(Interval) ->
    erlang:send_after(Interval, self(), world).

extract_hosts(#dns_rec{anlist=ANList}) ->
    [data_to_node_name(Data) || #dns_rr{data=Data} <- ANList].

data_to_node_name({A, B, C, D}) ->
    list_to_atom(lists:flatten(io_lib:format("derl@~b.~b.~b.~b", [A, B, C, D]))).
