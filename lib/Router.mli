val ( >> ) : ('a, 'b) Routes.path -> 'a -> 'b Routes.route
val route : ([> `Not_found ] as 'a) Routes.router -> Http.Request.t -> 'a
val method_ : Http.Method.t -> ('a, 'b) Routes.path -> ('a, 'b) Routes.path
val get : ('a, 'b) Routes.path -> ('a, 'b) Routes.path
val post : ('a, 'b) Routes.path -> ('a, 'b) Routes.path
