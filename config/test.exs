use Mix.Config
config :ifs_q, IfsQ, eventer_port: 4848
config :ifs_q, eventer_url: "http://localhost:4848" 
config :ifs_q, IfsQ, unit_table: :test_unit_pids
config :ifs_q, IfsQ, dispatch_port: 5250

