xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $authorsWithEntries := 
  doc('../authors_3.0.xml')//tei:text//(tei:persName | tei:persona | tei:person | tei:org)[@xml:id]/@xml:id/data(.)[. ne ''];
declare variable $prefix := "a:";

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
      return
      (
        <person xml:id="{$id}">
          <persName>
            <forename></forename>
            <surname></surname>
          </persName>
          <gender value="" evidence="conjecture"/>
        </person>,
        '

'
      )
    }
  </listPerson>
