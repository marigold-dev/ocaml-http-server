let _route = Routes.(s "echo" /? nil)

let request_handler _ = Piaf.Response.create `OK

let () =
  Eio_main.run @@ fun env ->
  Eio.Switch.run @@ fun sw ->
  print_endline "Server started";
  let port = 8080 in
  let config = Piaf.Server.Config.create port in
  let server = Piaf.Server.create ~config request_handler in
  let _ = Piaf.Server.Command.start ~sw env server in
  ()