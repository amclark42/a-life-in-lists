xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "text";

(: Sorting options :)
declare variable $sortByCount := false();

declare variable $readings := doc('../readings_3.0.xml')//tei:listEvent/tei:event;
declare variable $biblStructs := doc('../booksRead_3.0.xml')//tei:listBibl/tei:biblStruct[@xml:id];

(: Change this to your XPath query. :)
declare variable $query := 
  $readings//tei:ref[@target]/substring-after(@target/data(.),'b:');

let $distinctValues := distinct-values($query)
let $listOfCounts :=  
    for $value in $distinctValues
    let $count := count($query[. eq $value])
    let $eventMatches := $readings[descendant::tei:ref[@target]/substring-after(@target/data(.),'b:') eq $value]
    let $biblMatch := $biblStructs[@xml:id eq $value]
    let $title := $biblMatch/tei:monogr/tei:title/normalize-space(.)
    let $isComic := 
      if ( exists( $biblMatch/tei:monogr/tei:imprint/tei:catRef[@target/data(.) eq '#tag.comics'] ) ) then
        'comics'
      else ''
    order by
      if ( $sortByCount ) then () else $value,
      $count descending, 
      $value
    return 
      (: Cut out singletons UNLESS there is an indication that the book was in some way a reread. :)
      if ( $count ge 2 or exists($eventMatches/tei:p/text()[matches(.,'reread','i')]) ) then
        (: Tab-delimited data within rows. :)
        let $cells := ( $count cast as xs:string, $value, $title, $isComic )
        return string-join($cells, '&#9;')
      else ()
return 
  (: Separate each row with a newline. :)
  string-join($listOfCounts,'&#13;')