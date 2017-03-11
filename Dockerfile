FROM erlang:18

COPY . /usr/app

WORKDIR /usr/app

RUN make release

ENV RELX_REPLACE_OS_VARS true

CMD ["./_build/default/rel/disterltest/bin/disterltest", "foreground"]
