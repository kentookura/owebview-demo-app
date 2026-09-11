type body = Cohttp_eio.Body.t
type response = Cohttp_eio.Server.response
type handler = Http.Request.t -> body -> response

val default_max_body_size : int
val read_body : ?max_size:int -> Cohttp_eio.Body.t -> string

type 'a request = { route : 'a; request : Http.Request.t; body : body }

val serve :
  ?port:int ->
  ?backlog:int ->
  ?max_connections:int ->
  env:< net : [> [> `Generic ] Eio.Net.ty ] Eio.Resource.t ; .. > ->
  router:([> `Not_found ] as 'a) Routes.router ->
  ('a request -> Cohttp_eio.Server.response) ->
  'b

val with_content_type : Http.Header.t option -> string -> Http.Header.t

val respond_string :
  ?headers:Http.Header.t ->
  status:Http.Status.t ->
  content_type:string ->
  string ->
  Cohttp_eio.Server.response

val empty :
  ?headers:Http.Header.t -> Http.Status.t -> Cohttp_eio.Server.response

val text :
  ?headers:Http.Header.t ->
  Http.Status.t ->
  string ->
  Cohttp_eio.Server.response

val html :
  ?headers:Http.Header.t ->
  Http.Status.t ->
  Pure_html.node ->
  Cohttp_eio.Server.response

val raw :
  ?headers:Http.Header.t ->
  content_type:string ->
  Http.Status.t ->
  string ->
  Cohttp_eio.Server.response

val json :
  ?headers:Http.Header.t ->
  Http.Status.t ->
  'a Jsont.t ->
  'a ->
  Cohttp_eio.Server.response

val redirect :
  ?permanent:bool ->
  ?headers:Http.Header.t ->
  string ->
  Cohttp_eio.Server.response

val file :
  ?headers:Http.Header.t ->
  mime:string ->
  Http.Status.t ->
  [> Eio.Fs.dir_ty ] Eio.Path.t ->
  Cohttp_eio.Server.response
