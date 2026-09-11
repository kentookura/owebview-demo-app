type body = Cohttp_eio.Body.t
type response = Cohttp_eio.Server.response
type handler = Http.Request.t -> body -> response

let default_max_body_size = 10 * 1024 * 1024

let read_body ?(max_size = default_max_body_size) (body : Cohttp_eio.Body.t) :
    string =
  Eio.Buf_read.(parse_exn take_all) body ~max_size

type 'a request = {
  route : 'a;
  request : Http.Request.t;
  body : Cohttp_eio.Body.t;
}

let serve ?(port = 8080) ?(backlog = 128) ?max_connections ~env ~router handler
    =
  Eio.Switch.run @@ fun sw ->
  let net = Eio.Stdenv.net env in
  let router request = Router.(route @@ one_of router) request in
  let socket =
    Eio.Net.listen net ~sw ~backlog ~reuse_addr:true
      (`Tcp (Eio.Net.Ipaddr.V4.any, port))
  in
  let server =
    Cohttp_eio.Server.make
      ~callback:(fun _conn request body ->
        let route = router request in
        handler { route; request; body })
      ()
  in
  Cohttp_eio.Server.run ?max_connections socket server ~on_error:(fun exn ->
      Eio.traceln "Server: %a" Eio.Exn.pp exn)

let with_content_type headers content_type =
  Http.Header.add_unless_exists
    (Option.value headers ~default:(Http.Header.init ()))
    "content-type" content_type

let respond_string ?headers ~status ~content_type body =
  Cohttp_eio.Server.respond_string ~status
    ~headers:(with_content_type headers content_type)
    ~body ()

let empty ?headers status =
  Cohttp_eio.Server.respond_string ?headers ~status ~body:"" ()

let text ?headers status body =
  respond_string ?headers ~status ~content_type:"text/plain; charset=utf-8" body

let html ?headers status body =
  respond_string ?headers ~status ~content_type:"text/html; charset=utf-8"
    Pure_html.(to_string body)

let raw ?headers ~content_type status body =
  respond_string ?headers ~status ~content_type body

let json ?headers status jsont v =
  match Jsont_bytesrw.encode_string jsont v with
  | Ok body ->
      respond_string ?headers ~status ~content_type:"application/json" body
  | Error msg -> invalid_arg (Printf.sprintf "Server.json: %s" msg)

let redirect ?(permanent = false) ?headers location =
  let status : Http.Status.t =
    if permanent then `Moved_permanently else `Found
  in
  let headers =
    Http.Header.add
      (Option.value headers ~default:(Http.Header.init ()))
      "location" location
  in
  Cohttp_eio.Server.respond_string ~status ~headers ~body:"" ()

let file ?headers ~mime status path : Cohttp_eio.Server.response =
 fun writer ->
  Eio.Path.with_open_in path @@ fun flow ->
  Cohttp_eio.Server.respond ~status
    ~headers:(with_content_type headers mime)
    ~body:flow () writer
