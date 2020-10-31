
$URL  = "https://accounts.google.com/signin"
$URL2 = "https://twitter.com/login"
$URL3 = "https://www.instagram.com/?hl=en"
$URL4 = "https://facebook.com"
$URL5 = "https://www.reddit.com/"
$chrome = (Start-Process chrome.exe -Argumentlist @('-incognito',$URL,$URL2,$URL3,$URL4,$URL5))

CLS

