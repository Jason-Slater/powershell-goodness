
$URL  = "https://accounts.google.com/signin"
$URL2 = "https://twitter.com/login"
$URL3 = "https://www.instagram.com/?hl=en"
$URL4 = "https://facebook.com"
$URL5 = "https://www.reddit.com/"
$chrome = (Start-Process chrome.exe -Argumentlist @('-incognito',$URL,$URL2,$URL3,$URL4,$URL5))

CLS



#$URL1  = "https://accounts.google.com/signin/v2/identifier?service=mail&passive=1209600&osid=1&continue=https%3A%2F%2Fmail.google.com%2Fmail%2Fu%2F0%2F&followup=https%3A%2F%2Fmail.google.com%2Fmail%2Fu%2F0%2F&emr=1&flowName=GlifWebSignIn&flowEntry=ServiceLogin"
$URL2  = "https://twitter.com/login"
$URL3  = "https://www.instagram.com/?hl=en"
$URL4  = "https://facebook.com"
$URL5  = "https://www.reddit.com/"
(Start-Process firefox.exe -Argumentlist @('-incognito',$URL2,$URL3,$URL4,$URL5))

CLS