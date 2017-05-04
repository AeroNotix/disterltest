provider "google" {
    region = "${var.region}"
    project = "${var.project}"
    credentials = "${file("/gcloud/credentials")}"
}

variable username {}
variable password {}
variable region {}
variable project {}
variable zone {}

resource "google_container_cluster" "disterltest" {
    name = "disterltest"
    description = "disterltest"
    zone = "${var.zone}"
    initial_node_count = "1"

    master_auth {
        username = "${var.username}"
        password = "${var.password}"
    }

    node_config {
        machine_type = "n1-standard-1"

        oauth_scopes = [
            "https://www.googleapis.com/auth/compute",
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ]
    }
}
