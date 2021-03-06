module LiveColor where

import Color
import Graphics.Collage (..)
import Graphics.Element (..)
import Http
import List
import Markdown
import Rebase (decimalFromHex)
import Signal
import String
import Text as T
import Window

------------
-- LAYOUT --
------------
scene : (Int,Int) -> List (String, String) -> Element
scene (w,h) ls =
    let
        ds = T.defaultStyle
        titleStyle = T.style { typeface = ["BentonSansBold","sans"]
                             , height = Just 80
                             , color = Color.charcoal
                             , bold = False
                             , italic = False
                             , line = Nothing
                             }
        title = (width w << T.centered << titleStyle << T.fromString) "GitHub Language Colors"
        footer = color Color.lightGray <| container w 200 middle <| Markdown.toElement """
Built with [Elm](http://elm-lang.org/) for the fun of it,

heavily inspired by GitHub's own [version](http://github.github.io/linguist/),

and [open-sourced](https://github.com/hoosierEE/github-colors-live)."""
        txtFn = T.centered << T.height 26 << T.typeface ["BentonSansRegular","sans"] << T.fromString
        txtTiny = T.centered << T.height 12 << T.typeface ["BentonSansRegular","sans"] << T.fromString
        clrFn = rgbFromCss -- Color.toHsl << rgbFromCss
        -- sorted lists
        alphs = List.map (\(a,b) -> (txtFn a, clrFn b)) ls
        hues = List.sortBy (.hue << Color.toHsl << snd) alphs
        columnAlpha = (txtFn "sorted alphabetically...", Color.rgb 244 244 244) :: alphs
        columnHue = (txtFn "...and by hue", Color.rgb 244 244 244) :: hues
        cols = [columnAlpha,columnHue]
        boxed (txt,clr) =
            let mw = w // List.length cols
                hc = Color.toHsl clr
                hc' = Color.hsl hc.hue hc.saturation hc.lightness
                rc = Color.toRgb clr
                rc' = Color.rgb rc.red rc.green rc.blue
            in width mw <| color rc' <| container mw 60 middle (flow down [txt, txtTiny <| toString rc'])
        fds t = flow down <| List.map boxed t
    in flow down [title, flow right <| List.map fds cols, footer]

------------
-- WIRING --
------------
main = Signal.map2 scene Window.dimensions clrs

------------
-- PORTS --
------------
port clrs : Signal (List (String,String)) -- (INPUT) result from YAML->JSON->filtering
port yamlReq : Signal String -- (OUTPUT) Http SEND GET the yaml string
port yamlReq =
    let
        url = Signal.constant "https://cdn.rawgit.com/github/linguist/master/lib/linguist/languages.yml"
        res : Signal (Http.Response String)
        res = Http.sendGet url
        dResponse : Http.Response String -> String
        dResponse result = case result of
            Http.Success msg -> msg
            Http.Waiting -> ""
            Http.Failure _ _ -> ""
    in Signal.map dResponse res

---------------
-- UTILITIES --
---------------
-- converts "#rgb" or "#rrggbb" hex color string into {r,g,b} integers
rgbFromCss : String -> Color.Color
rgbFromCss cssColorString =
    let hexColor = if (String.left 1 cssColorString) == "#"
                   then String.dropLeft 1 cssColorString -- drop the "#"
                   else cssColorString
        str =
            if (String.length hexColor == 3) then -- (r,g,b) -> (rr,gg,bb)
               let dub ids = String.concat <| List.map (\(a,b) -> String.repeat 2 <| String.slice a b hexColor) ids
               in dub [(0,1),(1,2),(2,3)]
            else hexColor
        dfh (a,b) = decimalFromHex <| String.slice a b str
        rgbIndexes = [(0,2),(2,4),(4,6)]
        [r,g,b] = List.map dfh rgbIndexes
    in Color.rgb r g b

