xquery version "3.1";

 (:  LIBRARIES  :)
  import module namespace ctab="http://www.wwp.northeastern.edu/ns/count-sets/functions"
    at "https://raw.githubusercontent.com/NEU-DSG/wwp-public-code-share/main/counting_robot/count-sets-library.xql";
  import module namespace proc="http://basex.org/modules/proc";
  import module namespace file="http://expath.org/ns/file";
 (:  NAMESPACES  :)
  declare namespace array="http://www.w3.org/2005/xpath-functions/array";
  declare namespace Composite="http://ns.exiftool.org/Composite/1.0/";
  declare namespace ID3v1="http://ns.exiftool.org/ID3/ID3v1/1.0/";
  declare namespace ID3v2_3="http://ns.exiftool.ca/ID3/ID3v2_3/1.0/";
  declare namespace ID3v2_4="http://ns.exiftool.ca/ID3/ID3v2_4/1.0/";
  declare namespace ItemList="http://ns.exiftool.ca/QuickTime/ItemList/1.0/";
  declare namespace map="http://www.w3.org/2005/xpath-functions/map";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
  declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
  declare namespace System="http://ns.exiftool.org/File/System/1.0/";
  declare namespace tei="http://www.tei-c.org/ns/1.0";
  declare namespace xspf="http://xspf.org/ns/0/";
 
 (:  OPTIONS  :)
  (:declare option output:indent "no";:)

(:~
  Use the utility ExifTool to compile metadata from music files, then generate playlists in the XSPF format
  (https://xspf.org) using keys in the ID3 Comment tags.
  
  @author Ash Clark
  2022
 :)
 
(:  VARIABLES  :)
  declare variable $home-directory as xs:string := "/home/ash/";
  declare variable $lists-directory as xs:string := 
    concat($home-directory,"Documents/a-life-in-lists/");
  declare variable $music-directory as xs:string := 
    concat($home-directory,"Music/");
  (: The types of output that this script should return:
       "musicMetadata":  The RDF/XML returned by ExifTool. Whether or not this is returned as output by this 
                         script, it will be saved to the playlists directory.
       "playlistCounts": A counting robot report on the number of songs matching each smart playlist key in 
                         ../smartPlaylists.xml.
       "xspfPlaylists":  One XSPF playlist per smart playlist key in ../smartPlaylists.xml. Whether or not they are
                         returned as output by this script, they will be saved to the playlist directory.
   :)
  declare variable $output as map(xs:string, xs:boolean) := map {
      'musicMetadata': false(),
      'playlistCounts': false(),
      'xspfPlaylists': true()
    };
  declare variable $playlist-keys as element()* :=
    doc('../smartPlaylists.xml')//tei:text//tei:label;

(:  FUNCTIONS  :)
  
  (: Use the counting robot to identify playlist keywords stored in "Comment" metadata fields. :)
  declare function local:count-playlist-keys($metadata) {
    (: Playlist phrases are separated by a semicolon, e.g. "The Drive!; Singable" :)
    let $allPhrases :=
      $metadata//*:Comment/tokenize(., ';') ! normalize-space()
    let $countingRobotReport := ctab:get-counts($allPhrases[. = $playlist-keys/normalize-space(.)])
    let $reportByRows := tokenize($countingRobotReport, $ctab:newlineChar)[not(matches(., '^1\t'))]
    (: There is always more than one instance of a playlist keyword. A report without the long tail will still 
      contain repeated phrases that are not playlist keywords, but there will be significantly fewer of them! :)
    (:let $tailless := ctab:join-rows($reportByRows) => ctab:report-to-map():)
    return ctab:report-to-map($reportByRows)
  };
  
  declare function local:get-files-metadata() {
    let $argumentSeq := (
        "-r",
        "-xmlFormat",
        "-ID3v2_4:Title", "-ID3v2_3:Title", "-ID3v1:Title",
        "-ID3v2_4:Artist", "-ID3v2_3:Artist", "-ID3v1:Artist",
        "-ID3v2_4:Album", "-ID3v2_3:Album", "-ID3v1:Album",
        "-ID3v2_4:Comment", "-ID3v2_3:Comment",
        "-System:FileName", "-System:FileModifyDate",
        "-Composite:Duration",
        $music-directory
      )
    (: ExifTool returns an error code 1 when run in recursive mode, so try to treat the output as XML before 
      falling back on the contents of the error element. :)
    let $processOut := proc:execute('exiftool', $argumentSeq)
    return try {
        parse-xml($processOut//output/text())
      } catch * {
        $processOut//error
      }
  };

(:  MAIN QUERY  :)

let $musicMetadata := local:get-files-metadata()
(: Generate playlists in XSPF format, using smart playlist criteria. :)
let $playlistsFromSmart :=
  for $smartKey in $playlist-keys/normalize-space(.)
  let $tracks :=
    $musicMetadata//rdf:Description[*:Comment[contains(., $smartKey)]
                                             (: Only include NOPE'd songs on the NOPE playlist. :)
                                             [$smartKey eq 'NOPE' or not(contains(., 'NOPE'))]
                                   ]
  let $xspfPlaylist :=
    <playlist version="1" xmlns="http://xspf.org/ns/0/">
      <title>{ $smartKey }</title>
      {
        (: If there's a description of this playlist key available, use it in an annotation. :)
        let $playlistDesc :=
          $playlist-keys[normalize-space(.) eq $smartKey]
                        /following-sibling::*[1][self::tei:item]/normalize-space(.)
        return
          if ( exists($playlistDesc) ) then
            <annotation xmlns="http://xspf.org/ns/0/">{ $playlistDesc }</annotation>
          else ()
      }
      <trackList>
      {
        for $track in $tracks
        return
          <track xmlns="http://xspf.org/ns/0/">
            <title>{ $track//*:Title[1]/text() }</title>
            <creator>{ $track//*:Artist[1]/text() }</creator>
            <album>{ $track//*:Album[1]/text() }</album>
            <location>{ substring-after($track/@rdf:about, $home-directory) }</location>
          </track>
      }
      </trackList>
    </playlist>
  let $playlistPath :=
    let $filename := replace(translate($smartKey, ",!''", ''), '\s', '_')
    return concat($lists-directory,'playlists/',$filename,'.xml')
  (: Save the playlist to the appropriate directory. :)
  return (
      file:write($playlistPath, $xspfPlaylist, map {
          'indent': 'yes',
          'media-type': 'application/xspf+xml',
          'method': 'xml'
        }),
      $xspfPlaylist
    )
return (
  (: Save a copy of the ExifTool report. :)
  if ( $musicMetadata[self::error] ) then ()
  else
    let $hostname := proc:execute('hostname')//output/normalize-space(.)
    let $reportPath := concat($lists-directory,'playlists/all-music_',$hostname,'.xml')
    return file:write($reportPath, $musicMetadata, map { 
        'method': 'xml',
        'indent': 'yes'
      })
  ,
  if ( $output?xspfPlaylists ) then
    $playlistsFromSmart
  else ()
  ,
  if ( $output?musicMetadata ) then
    $musicMetadata
  else ()
  ,
  if ( $output?playlistCounts ) then
    local:count-playlist-keys($musicMetadata)
  else ()
)
