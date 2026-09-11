include Routes

let ( >> ) = Routes.( @--> )

let target (request : Http.Request.t) =
  Http.Method.to_string (Http.Request.meth request)
  ^ Http.Request.resource request

let route (router : 'a Routes.router) (request : Http.Request.t) :
    [> `Not_found ] as 'a =
  match Routes.match' router ~target:(target request) with
  | Routes.FullMatch r | Routes.MatchWithTrailingSlash r -> r
  | Routes.NoMatch -> `Not_found

let method_ meth path = Routes.s (Http.Method.to_string meth) path
let get path = method_ `GET path
let post path = method_ `POST path
