# SnipsChat
Converts chat messages in json with extracting @mentions (emoticons) and valid http(s)://links . Also puts the title of the link 
by extracting the html, and parsing it. If cannot load the link or network issue then it shows json box in red otherwise if it is done 
it will show json box in green. If links are still processed for finding the title it will show the box in white.


###Overall Design
The over design is around four stages. 

1. Local Parsing 

2. Fetching HTML

3. Parsing HTML and finding title

4. Updating UI

####Local Parsing
For local parsing regular expression are used to extract mentions. Mentions are having word letters not just A-Z letters but word letters 
as defined in apple documentation to include word letters from whole of Unicode covering languages other than English as well. 

URLs are extracted using a regular expression that rejects invalid urls such as http://# or http://.. or http:/// . This is however not bombproof.

####Fetching HTML
For fetching HTML, NSOperationQueue is used to fetch html in background

####Parsing HTML
HTML is parsed using excellent parser by Matthias Hochgatterer - https://github.com/brutella/Axt . It is a stream parser based on libxml2
so it ensure we do not have to load the entire html and we do not even have to download the entire html. Once we have title we 
simply stop downloading the html to save time and bandwidth. Title is found by looking for title element in the head.





