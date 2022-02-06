xquery version "3.1";

  (:declare boundary-space preserve;:)
 (:  LIBRARIES  :)
  import module namespace proc="http://basex.org/modules/proc";
 (:  NAMESPACES  :)
  declare namespace array="http://www.w3.org/2005/xpath-functions/array";
  declare namespace Composite="http://ns.exiftool.org/Composite/1.0/";
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
  Use the utility ExifTool to compile metadata from my music files.
  
  `exiftool -xmlFormat -sep "; " -r -ID3v2_3:Comment -ID3v2_4:Comment ~/Music/ > ~/Documents/inProgress/music-comments_shadowedhills.xml`
  
  
  @author Ash Clark
  2022
 :)
 
(:  VARIABLES  :)
  declare variable $music-directory-path as xs:string := "/home/ash/Music/";

(:  FUNCTIONS  :)
  
  declare function local:get-files-metadata() {
    let $argumentSeq := (
        (:"-r",:)
        "-xmlFormat",
        "-ID3v2_3:Title",
        "-ID3v2_3:Artist",
        "-ID3v2_3:Album",
        "-ID3v2_3:Comment",
        "-ID3v2_4:Comment",
        "-System:FileName",
        "-Composite:Duration",
        $music-directory-path
      )
    return
      proc:system('exiftool', $argumentSeq)
  };

(:  MAIN QUERY  :)

local:get-files-metadata()

