
(* Empty route *)
let route_a _ = Piaf.Response.create `OK


(* with deserialization, and a non empty request/response *)
module Request = struct
  type operation = Operation_noop of {
    sender: string
  } [@@deriving of_yojson]

  type initial = 
    | Initial_operation of {
      hash: string;
      nonce: string;
      level: string;
      operation: operation
  } [@@deriving of_yojson]
  
  type t = {
    key: string;
    signature: string;
    initial: initial
  } [@@deriving of_yojson]
end

module Response = struct
  type t = {hash: string} [@@deriving yojson_of]

end

let route_b req =  
  let Piaf.Server.Handler.{ request : Piaf.Request.t; _ } = req in
  let body = request.body
    |> Piaf.Body.to_string
    |> Result.get_ok
    |> Yojson.Safe.from_string
    |> Request.t_of_yojson
  in
  let Request.{initial; key=_; signature=_} = body in  
  let Request.Initial_operation {hash; _} = initial in
  let response = {hash = hash}
    |> Response.yojson_of_t
    |> Yojson.Safe.to_string
    |> Piaf.Body.of_string
  in
  Piaf.Response.create ~body:response `OK

let request_handler req = 
  let Piaf.Server.Handler.{ request : Piaf.Request.t; _ } = req in
  let target = request.target in
  match target with
    | "/route-a" -> route_a req
    | "/route-b" -> route_b req
    | _ -> Piaf.Response.create `Not_found

let () =
  Eio_main.run @@ fun env ->
  Eio.Switch.run @@ fun sw ->
  print_endline "Server started";
  let port = 8080 in
  let config = Piaf.Server.Config.create ~buffer_size:0x1000 ~domains:1 port in
  let server = Piaf.Server.create ~config request_handler in
  let _ = Piaf.Server.Command.start ~sw env server in
  ()
