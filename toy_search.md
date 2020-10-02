## Toy Search Space
### manifest
manifest.json structure
```json
"per_request_type":{
  "ServerCreate":{
    "paths": {
      "bd0ce9ef801df6ab9edbd12d57d77bdd5e12aed46383d88cceb2ef0b0fb59a4e": {
        "g":{
          "nodes":{
            "tracepoint_id":"emreates/usr/lib/python3/dist-packages/cliff/app.py:363:openstackclient.shell.App.run_subcommand",
            "variant":"Entry",
            "key_value_pair":{
              "host":{
                "Str":"cp-1.sir-qv81184.tracing-pythia-pg0.utah.cloudlab.us"
              }
              "lock_queue":{}
             }
          }
        }
      }
    }
    "occurances": {
      "83ed0ae8bf2b98be3da672eac449ef67f11c27600befd433063e773af5217b4d":3
    },
    "added_pahts":19,
    "entry_points":{
      "nova/usr/local/lib/python3.6/dist-packages/nova/scheduler/manager.py:205:nova.scheduler.manager.SchedulerManager.delete_instance_info"
    }
    "synchronization_points":{},
    "request_type_tracepoints":{
      "emreates/usr/local/lib/python3.6/dist-packages/openstackclient/compute/v2/server.py:662:openstackclient.compute.v2.server.CreateServer.take_action"
    }
}
```
tracepoint_id
```
emreates/usr/lib/python3/dist-packages/cliff/app.py:363:openstackclient.shell.App.run_subcommand
```
### offline_traces.txt
offline_traces.txt is a collection of all traces. Each line in this file has a corresponding .dot file

### manifest.json
manifest.json is summary of search space
