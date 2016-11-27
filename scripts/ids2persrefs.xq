xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $ids :=
"copeland.k
stiffler.a
weathing.l
visel.l
wilgus.a
espinosa.a
handwerk.km
edwards.d
martins.aj
horrocks.s
thomas.b
ebenstei.k
cairns.j
hughes.k
khor.sy
delliqua.b
maclean.wm
closson.t
goudreau.c
black.r
smith.n
dukes.r
reed.g";
declare variable $prefix := "a:";

<listPerson xmlns="http://www.tei-c.org/ns/1.0">
  {
    for $id in tokenize($ids,'\n')
    let $idref := concat($prefix, $id)
    order by $id
    return
      <persName ref="{$idref}"/>
  }
</listPerson>