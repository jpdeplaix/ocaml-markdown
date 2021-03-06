(* Copyright (C) 2009 Mauricio Fernandez <mfp@acm.org> *)

module Make_xhtml (Xhtml : Xhtml_sigs.T) = struct

open Markdown
open Xhtml

let rec elm_to_html ~render_pre ~render_link ~render_img elm =
  let self = elm_to_html ~render_pre ~render_link ~render_img in
  let item l = li (List.map self l)

  in match elm with
      Normal text -> p (par_text_to_html ~render_link ~render_img text)
    | Pre (s, kind) -> begin match kind with
          Some k -> render_pre ~kind:k s
        | None -> pre [pcdata s]
      end
    | Heading (l, text) ->
        let f =
          match l with 1 -> h1 | 2 -> h2 | 3 -> h3 | 4 -> h4 | 5 -> h5 | _ -> h6
        in f (par_text_to_html render_link render_img text)
    | Quote ps -> blockquote (List.map self ps)
    | Ulist (fst, others) ->
        ul (item fst) (List.map item others)
    | Olist (fst, others) ->
        let item l = li (List.map self l) in
          ol (item fst) (List.map item others)

and par_text_to_html ~render_link ~render_img =
  List.map (text_to_html ~render_link ~render_img)

and text_to_html ~render_link ~render_img = function
    Text s -> pcdata s
  | Emph s -> em [pcdata s]
  | Bold s -> b [pcdata s]
  | Struck l -> del (List.map (text_to_html ~render_link ~render_img) l)
  | Code s -> code [pcdata s]
  | Anchor id ->
      (*  would like to do
            a ~a:[XHTML.M_01_00.a_name_01_00 id] []
          but that'd require switching to M_01_00 everywhere, so cheap hack *)
      b ~a:[a_id id] []
  | Link href -> begin match href.href_target with
        s when String.length s >= 1 && s.[0] = '#' ->
          a ~a:[a_href (uri_of_string s)] [pcdata href.href_desc]
      | _ -> render_link href
    end
  | Image href -> render_img href

let to_html ~render_pre ~render_link ~render_img l =
  List.map (elm_to_html ~render_pre ~render_link ~render_img) l

end

module Make_html5 (Html5 : Html5_sigs.T) = struct

open Markdown
open Html5

let rec elm_to_html ~render_pre ~render_link ~render_img elm =
  let self = elm_to_html ~render_pre ~render_link ~render_img in
  let item l = li (List.map self l)

  in match elm with
      Normal text -> p (par_text_to_html ~render_link ~render_img text)
    | Pre (s, kind) -> begin match kind with
          Some k -> render_pre ~kind:k s
        | None -> pre [pcdata s]
      end
    | Heading (l, text) ->
        let f =
          match l with 1 -> h1 | 2 -> h2 | 3 -> h3 | 4 -> h4 | 5 -> h5 | _ -> h6
        in f (par_text_to_html render_link render_img text)
    | Quote ps -> blockquote (List.map self ps)
    | Ulist (fst, others) ->
        ul (List.map item (fst :: others))
    | Olist (fst, others) ->
        let item l = li (List.map self l) in
          ol (List.map item (fst :: others))

and par_text_to_html ~render_link ~render_img =
  List.map (text_to_html ~render_link ~render_img)

and text_to_html ~render_link ~render_img = function
    Text s -> pcdata s
  | Emph s -> em [pcdata s]
  | Bold s -> b [pcdata s]
  | Struck l -> del (List.map (text_to_html ~render_link ~render_img) l)
  | Code s -> code [pcdata s]
  | Anchor id ->
      (*  would like to do
            a ~a:[XHTML.M_01_00.a_name_01_00 id] []
          but that'd require switching to M_01_00 everywhere, so cheap hack *)
      b ~a:[a_id id] []
  | Link href -> begin match href.href_target with
        s when String.length s >= 1 && s.[0] = '#' ->
          a ~a:[a_href (uri_of_string s)] [pcdata href.href_desc]
      | _ -> render_link href
    end
  | Image href -> render_img href

let to_html ~render_pre ~render_link ~render_img l =
  List.map (elm_to_html ~render_pre ~render_link ~render_img) l

end
