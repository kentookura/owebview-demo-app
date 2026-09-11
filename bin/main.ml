open Demo_app
open Router
open Server

let router : [ `Home | `Htmlact | `Increment | `Not_found ] Router.t =
  [
    get /? nil >> `Home;
    get / s "htmlact.js" /? nil >> `Htmlact;
    post / s "increment" /? nil >> `Increment;
  ]

let port = 8080

let serve () =
  Eio_main.run @@ fun env ->
  serve ~port ~env ~router @@ fun { route; _ } ->
  match route with
  | `Home -> html `OK Content.(index ())
  | `Htmlact -> raw ~content_type:"text/javascript" `OK Content.htmlact
  | `Increment -> html `OK Content.(increment ())
  | `Not_found -> empty `Not_found

let () =
  let _ = Thread.create serve () in
  let open Webview in
  let webview = create ~debug:true () in
  set_title webview "demo-app";
  set_size webview ~width:800 ~height:600 Webview.Hint_none;
  navigate webview (Printf.sprintf "http://127.0.0.1:%d/" port);
  run webview;
  destroy webview
