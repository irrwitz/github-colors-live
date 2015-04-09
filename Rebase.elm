module Rebase (decimalFromHex) where
-- module Hex where

import String (indexes,fromChar,toList)
import List (map,head,reverse,indexedMap,foldr)
-- import Text (asText)
-- main = asText <| decimalFromHex "010"

-- decimalFromHex : String -> Int
decimalFromHex hexString =
    let xs = reverse <| toList hexString
        vals = map (\c-> (head <| indexes (fromChar c) "0123456789ABCDEF0123456789abcdef")) xs
        powered = indexedMap (\idx val -> 16 ^ idx * (val % 16)) vals
     in foldr (+) 0 powered

-- hexFromDecimal : Int -> String
-- hexFromDecimal decimal =
--     toString decimal