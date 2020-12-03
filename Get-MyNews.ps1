param(
    [String]$ExportFolder = $PSScriptRoot
)

$Header = @"
  <title>My News Sites</title>
  <style>

  body{
    background: linear-gradient(to right, #003366 0%, #000009 100%);
  }

  h1{ 
    font-family: arial;
  } 

  a {
    color: white;
    text-decoration: none;
  }

  #header {
    display:flex;
    justify-content:space-between;
    padding: 20px;
    text-align: center;
    color: white;
    font-size: 12px;
    border-bottom-left-radius: 20px;
    border-bottom-right-radius: 20px;
    width: 90%;
    margin-left: 4%;
  }

  .headerLinks {
    align-self:flex-end;
    display:flex;
  }

  table { 
    border: 1px solid #ddd;
    font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
    border-collapse: collapse;
    background-color:rgb(192,168,100,0.2);
    margin: 10px;
    width: 400px;
  } 
  caption{
    color: white;
  }
  th { 
    padding-top: 12px;
    padding-bottom: 12px;
    text-align: center;
    border-bottom: white 1px solid;
    color: white;
  } 

  td { 
    font-size: 13px; 
    padding: 15px; 
      color: white;
  } 

  tr:hover {
    background-color: rgb( 241, 196, 15,50%);
  }

  #container{
    display:flex;
    flex-wrap: wrap;
    padding:10px;
    margin-left: 8%
  }

  .linkItem{
    justify-content: space-between;
    padding: 10px;
  }

  #footer{
    justify-content:space-between;
    padding: 20px;
    background:   rgba(0, 0, 0, 0.75);
    color: white;
    font-size: 12px;
    width: 100%;
    text-align: center;
  }

  </style>
"@

function Get-TimeStamp {
  ((Get-Date -format d)) + " " + (Get-Date -Format t)
}
function Get-HeaderLinkHTMLString {

  param(
    [String]$Link,
    [String]$NameOfSite
  )

@"
  <div class=`"linkItem`">
    <h2><a href=`"$Link`" target=`"_blank`">$NameOfSite</a></h2> 
  </div>
"@
  
}
function Get-HackerNewsHTMLString {

  $HackerNewsLinks = (Invoke-WebRequest -Uri "https://news.ycombinator.com").Links

  if($PSVersionTable.PSVersion.Major -lt 7){
    $StoryLinks = $HackerNewsLinks | Where-Object {$_.Class -eq "storylink"} 
  }else{
    $StoryLinks = $HackerNewsLinks |  Where-Object {$_.OuterHTML -like '*class="storylink*'}
  }

  $HTMLString = @()
  $HTMLString += "<table>"
  $HTMLString += "<caption>Hacker News</caption>"

  foreach($Link in $StoryLinks){
    if($PSVersionTable.PSVersion.Major -lt 7){
      $HTMLString += "<tr>"
      $HTMLString += "$("<td><a href=`'$($Link.href)`'target=`'_blank`'>$($Link.InnerHTML)</a></td>")"
      $HTMLString += "</tr>"
    }else{
      $HTMLString += "<tr>"
      $HTMLString += "$("<td><a href=`'$($Link.href)`'target=`'_blank`'>$($Link.outerHTML -replace '<[^>]+>','')</a></td>")"
      $HTMLString += "</tr>"
    }
  }

  $HTMLString += "</table>"
  $HTMLString

}
function Get-RedditSubReddit{

  param(
    [String]$SubReddit
  )

  $RedditLinks = (Invoke-RestMethod -Uri https://www.reddit.com/r/$SubReddit/hot/.json).data.children.data
  $HTMLString = @()
  $HTMLString += "<table>"
  $HTMLString += "<caption>/r/$SubReddit</caption>"

  foreach($Link in $RedditLinks){
    $HTMLString += "<tr>"
    $HTMLString += "<td><a href=`'$($Link.Url)`' target=`"_blank`">$($link.title)</a></td>" 
    $HTMLString += "<td><a href=`'https://reddit.com$($Link.PermaLink)`' target=`"_blank`">Comments</a></td>" 
    $HTMLString += "</tr>"
  }

  $HTMLString += "</table>"
  $HTMLString

}

############################################################Start here###########################################################
$ErrorActionPreference = "Stop"

$HeaderLinksHash = @{
  FrontEndHappyHour = 'https://frontendhappyhour.com/'
  SyntaxFM = 'https://syntax.fm/'
  CodeNewbie = 'https://www.codenewbie.org/podcast'
} 

$ArrayOfSubreddits = @('programming','learnjavascript','news')

try{
  $Header | Out-File $ExportFolder\News.html
}catch{
  Write-Warning "Unable to output file to $ExportFolder"
  Write-Warning "Please confirm you have permission to the path above or try another path"
  Exit
}

$HTML = @"
<body>
  <div id=`"header`">
    <h1>My News Sites</h1>
      <div class=`"headerLinks`">
        $(
          foreach($Link in $HeaderLinksHash.Keys){
            Get-HeaderLinkHTMLString -Link $HeaderLinksHash[$Link] -NameOfSite $Link
          }
        )
      </div>
  </div>
  <div id=`"container`">
    $(Get-HackerNewsHTMLString)
      $(
        foreach($Subreddit in $ArrayOfSubreddits){
          Get-RedditSubReddit -SubReddit $Subreddit
        }
      )
  </div> 
  <div id=`"footer`">
    <h2><a href= `"https://github.com/mallockey/Get-MyNews`" target=`"_blank`">Github</a></h2>
      This page was created using PowerShell <br>
      Created on: $(Get-TimeStamp)
  </div>
</body>
"@

$HTML | Out-File $ExportFolder\News.html -Append

if(Test-Path $ExportFolder\News.html){
  Write-Output "Successfully exported to $($ExportFolder)"
}else{
  Write-Output "An unknown error occured, the News was file was not exported"
}