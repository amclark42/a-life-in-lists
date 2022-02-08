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
 
 (:  OPTIONS  :)
  (:declare option output:indent "no";:)

(:~
  Use the utility ExifTool to compile metadata from music files.
  
  `exiftool -xmlFormat -r -ID3v2_3:Comment -ID3v2_4:Comment ~/Music/`
  
  @author Ash Clark
  2022
 :)
 
(:  VARIABLES  :)
  declare variable $music-directory-path as xs:string := "/home/ash/Music/";
  declare variable $lists-directory-path as xs:string := "/home/ash/Documents/a-life-in-lists/";

(:  FUNCTIONS  :)
  
  declare function local:get-files-metadata() {
    let $argumentSeq := (
        "-r",
        "-xmlFormat",
        "-ID3v1:Title", "-ID3v2_3:Title",
        "-ID3v1:Artist", "-ID3v2_3:Artist",
        "-ID3v1:Album", "-ID3v2_3:Album",
        "-ID3v2_3:Comment", "-ID3v2_4:Comment",
        "-System:FileName",
        "-Composite:Duration",
        $music-directory-path
      )
    let $processOut := proc:execute('exiftool', $argumentSeq)
    return try {
        parse-xml($processOut//output/text())
      } catch * {
        $processOut//error
      }
  };

(:  MAIN QUERY  :)

let $musicMetadata := local:get-files-metadata()
(: Use the counting robot to find possible playlist keywords stored in "Comment" metadata fields. :)
let $possiblePlaylistKeys :=
  (: Playlist phrases are separated by a semicolon, e.g. "The Drive!; Singable" :)
  let $allPhrases :=
    $musicMetadata//*:Comment/tokenize(., ';') ! normalize-space()
  let $countingRobotReport := ctab:get-counts($allPhrases)
  (: There is always more than one instance of a playlist keyword. A report without the long tail will still 
    contain repeated phrases that are not playlist keywords, but there will be significantly fewer of them! :)
  let $tailless :=
    let $reportByRows := tokenize($countingRobotReport, $ctab:newlineChar)[not(matches(., '^1\t'))]
    return 
      ctab:join-rows($reportByRows) => ctab:report-to-map()
  return
    $tailless
return (
  (: Save a copy of the ExifTool report. :)
  if ( $musicMetadata[self::error] ) then ()
  else
    let $reportPath := concat($lists-directory-path,'exiftool-music.xml')
    return file:write($reportPath, $musicMetadata, map { 
        'method': 'xml',
        'indent': 'yes'
      })
  ,
  $possiblePlaylistKeys
  (: $musicMetadata :)
)
