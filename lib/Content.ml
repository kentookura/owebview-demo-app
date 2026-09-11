open Pure_html
open Pure_html.HTML

let htmlact = Htmlact_page_js.contents
let to_string = to_string
let of_htmlact : Htmlit.At.t -> attr = Htmlit.At.to_pair
let counter = Atomic.make 0
let counter_span n = span [ id "counter" ] [ txt "%d" n ]

let increment () =
  let n = Atomic.fetch_and_add counter 1 + 1 in
  counter_span n

let stylesheet =
  {css|
  body {
    margin: 4rem 1rem;
    display: flex;
    flex-direction: column;
    align-items: center;
    font-family: ui-monospace, monospace;
    color: #111;
  }
  #counter {
    display: block;
    font-size: 2rem;
    margin: 1.5rem 0;
    text-align: center;
  }
  button {
    font: inherit;
    padding: 0.4rem 1rem;
    border: 1px solid #111;
    background: #fff;
    color: #111;
    cursor: pointer;
  }
  button:hover { background: #111; color: #fff; }
  |css}

let index =
  html []
    [
      head []
        [
          title [] "demo-app";
          meta [ charset "utf-8" ];
          style [] "%s" stylesheet;
          script [ src "/htmlact.js"; defer ] "";
        ];
      body []
        [
          div []
            [
              p [] [ counter_span (Atomic.get counter) ];
              button
                [
                  of_htmlact (Htmlact.request ~method':`POST "/increment");
                  of_htmlact (Htmlact.target ":up #counter");
                  of_htmlact (Htmlact.effect' `Element);
                ]
                [ txt "Increment" ];
            ];
        ];
    ]
