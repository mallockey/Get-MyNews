A PowerShell script that fetches data from Hacker News and multiple sub reddits and formats them into a single HTML page. Planning to include other sources in future releases. 

## Usage
The script has one parameter, ExportFolder
The script has one parameter, ExportFolder. My default the script will export the News.html file to the script root.
`.\Get-MyNews.ps1 -ExportFolder 'C:\Users\MyUser\Desktop'`

![Usage](/Capture.PNG)

## Changing URLs


You can set which subreddit or link you want displayed by modifying the below hash table or sub reddit array: 

```
$HeaderLinksHash = @{
	FrontEndHappyHour = 'https://frontendhappyhour.com/'
	SyntaxFM = 'https://syntax.fm/'
	CodeNewbie = 'https://www.codenewbie.org/podcast'
}

$ArrayOfSubreddits = @('programming','learnjavascript')

```
