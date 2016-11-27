xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $doc := doc('../authors_3.0.xml');
declare variable $positionRange := 1 to 18;
declare variable $prefix := "a:";

<listPerson xmlns="http://www.tei-c.org/ns/1.0">
  {
    for $id in $doc//tei:listPerson/tei:person[position() = $positionRange]/@xml:id
    let $idref := concat($prefix, $id/data(.))
    order by $id/data(.)
    return
      <persName ref="{$idref}"/>
  }
</listPerson>