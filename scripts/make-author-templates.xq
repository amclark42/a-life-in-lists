xquery version "3.0";

(:  NAMESPACES  :)
  declare namespace tei="http://www.tei-c.org/ns/1.0";

(:  VARIABLES  :)
  declare variable $authorsWithEntries := 
    doc('../authors_3.0.xml')//tei:text//(tei:persName | tei:persona | tei:person | tei:org)[@xml:id]/@xml:id/data(.)[. ne ''];
  declare variable $prefix := "a:";

(:  FUNCTIONS  :)
  declare function local:capitalize($name as xs:string) {
    let $char1 := upper-case(substring($name, 1, 1))
    return concat($char1, substring($name, 2))
  };


(:  MAIN QUERY  :)

let $distinctRefs :=
  let $authorRefs := doc('../booksRead_3.0.xml')//tei:text//tei:biblStruct//@ref[starts-with(data(.), $prefix)]/data(.)
  return distinct-values($authorRefs)
let $missingAuthors :=
  for $ref in $distinctRefs
  let $idref := substring-after($ref, $prefix)
  return
    if ( $idref = $authorsWithEntries ) then ()
    else $idref
return
  <listPerson xmlns="http://www.tei-c.org/ns/1.0">
    {
      for $id in $missingAuthors
      let $surname := substring-before($id, '.')
      return
      (
        <person xml:id="{$id}">
          <persName>
            {
              if ( $surname ) then
              (
                <forename></forename>,
                <surname>{ local:capitalize($surname) }</surname>
              )
              else
                <name>{ local:capitalize($id) }</name>
            }
          </persName>
          <gender value="" evidence="conjecture"/>
        </person>,
        "

"
      )
    }
  </listPerson>
