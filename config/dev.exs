use Mix.Config
config :ifs_q, IfsQ, eventer_port: 4044
config :ifs_q, IfsQ, eventer_url: "http://localhost:4044" 
config :ifs_q, IfsQ, unit_table: :dev_unit_pids
config :ifs_q, IfsQ, dispatch_port: 5050
