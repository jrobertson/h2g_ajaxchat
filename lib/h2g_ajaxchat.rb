#!/usr/bin/env ruby

# file: h2g_ajaxchat.rb

# description: This gem makes it easier to build an AJAX chat project. 
#              Designed for Rack-rscript.


class DummyRequest

  def initialize()

    @session = {}
    @@id ||= 0 
    @session[:session_id] = @@id += 1

  end

  def session()
    @session
  end
end


class ChatCore

  attr_reader :messages, :users

  def initialize(debug: false)

    @debug = debug
    @messages = []
    @count = 0
    @users = {}
  end

  def login(req, username)
    req.session[:username] = username
  end

  def logout(req)
    req.session.clear
  end

  def chatter(req, newmsg=nil)

    @session = req.session
    append_message(newmsg) if newmsg
    
    return '' if @messages.empty?

    c = @session[:last_id]


    pos = if c then

      last_msg = @messages.find {|x| x.object_id.to_i == c}            
      last_msg ? @messages.index(last_msg)  + 1 : @messages.length - 1

    else

      return '' unless newmsg
      puts '_messages: ' + @messages.inspect
      @messages.length - 1
    end


    if @debug then
      puts 'pos: ' + pos.inspect
      puts '@messages: ' + @messages.inspect
    end    
    
    
    @session[:last_id] = @messages.last.object_id.to_i

    a = @messages[pos..-1].map do |t, id, u, msg|
    
      if block_given? then
        
        yield(t, id, u, msg)
        
      else
        
        s = "user%s: %s" % [id, msg]
        
        [t.strftime("%H:%M:%S"), s].join(' ')
      end
      
    end
                  
    a.join("\n")

    
  end

  protected

  def append_message(msg)

    u = @session[:username]
    id = @session[:session_id].to_s
    @users[id] = u.to_s
    
    @messages << [Time.now, id, u, msg]

  end

end

class DummyRws
  
  attr_accessor :req

  def initialize(obj)

    @obj = obj

  end

  def redirect(s)
    @obj.method(s.to_sym).call
  end
end

class WebPage

  def initialize(h={})
    @h = h
  end

  def to_css()
  end

  def to_html()
  end

  def to_js()
  end

  def to_s()
    html_template()
  end

  protected

  def html_template()

<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <style>
      #{to_css()}
    </style>
  </head>
#{to_html()}  
    <script>
      #{to_js()}
    </script>
  </body>
</html>
EOF
  end
end



class AjaxChat
  
  attr_reader :rws

  def initialize(chatobj, rws=DummyRws.new(self), debug: false)
    @chat, @rws, @debug = chatobj, rws, debug
  end
  
  def chatter(newmsg=nil)
    
    id, users = @rws.req.session[:session_id].to_s, @chat.users

    @chat.chatter(@rws.req, newmsg) do  |t, uid, username, msg|
          
      s2 = if id == uid then
        "you: %s" % msg
      else
        "%s: %s" % [users[uid], msg]
      end
      
      "<p><span id='time'>%s</span> %s</p>" % [t.strftime("%H:%M:%S"), s2]
      
    end        
    
    
  end

  def login()

    wp = WebPage.new

    def wp.to_html()
'
	<div id="loginform">
	<form action="login" method="post">
		<p>Please enter your name to continue:</p>
		<label for="name">Name:</label>
		<input type="text" name="name" id="name" autofocus="true"/>
		<input type="submit" name="enter" id="enter" value="Enter" />
	</form>
	</div>
'

    end

    def wp.to_s()
      to_html()
    end

    return wp

  end

  def login_post(username)

    @chat.login @rws.req, username
    @rws.redirect 'index'

  end
  
  def logout()

    wp = WebPage.new

    def wp.to_html()
'
	<div id="logoutform">
	<form action="logout" method="post">
		<p>Are you sure you want to logout?</p>
		<input type="submit" name="enter" id="enter" value="Yes" />
	</form>
	<a href="index">no, return to the chat page</a>
	</div>
	'

    end

    def wp.to_s()
      to_html()
    end

    return wp

  end  
  
  def logout_post()

    @chat.logout @rws.req
            
    wp = WebPage.new

    def wp.to_s()
      'You have successfully logged out'
    end

    return wp    

  end  

  def index()

    @rws.req.session[:username] ? view_index() : login()

  end
  
  def messages()
    @chat.messages
  end  
  
  def req(obj)
    @rws.req = obj
    self
  end
  
  def users()
    @chat.users
  end

  private

  def view_index()

    h = {username: @rws.req.session[:username]}

    wp = WebPage.new h

    def wp.to_css()
'
body {font-family: Arial;}
#chatbox {overflow: scroll; height: 40%}
div p span {colour: #dde}
'
    end

    def wp.to_html()
<<EOF
<body onload="refresh()">
  <div id="wrapper">
	  <div id="menu">
		  <p class="welcome">Welcome, <b> #{@h[:username]} </b></p>
		  <p class="logout"><a id="exit" href="logout">Exit Chat</a></p>
		  <div style="clear:both"></div>
	  </div>	
	  <div id="chatbox"></div>
    <input name="usermsg" type="text" id="usermsg" size="33" onkeyup='ajaxCall1(event.keyCode, this)' autofocus='true'/>

  </div>      

EOF
    end

    def wp.to_js()
<<EOF
  
function updateScroll(){
    var element = document.getElementById("chatbox");
    element.scrollTop = element.scrollHeight;
}  
// ajaxCall1();

function ajaxRequest(url, cFunction) {
  var xhttp;
  xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      cFunction(this);
    }
  };
  xhttp.open("GET", url, true);
  xhttp.send();
}


function ajaxCall1(keyCode, e) {
  if (keyCode==13){
    ajaxRequest('chatter?msg=' + e.value, ajaxResponse1)
    e.value = '';
  }  
}

function ajaxResponse1(xhttp) {
  e = document.getElementById('chatbox')
  s = xhttp.responseText;
  e.innerHTML = e.innerHTML + s;
  
  if (s.length > 1)
    updateScroll();
}

function refresh() {
  setInterval(ajaxCall2,2000);
}

function ajaxCall2() {
  ajaxRequest('chatter', ajaxResponse1)
}

EOF


    end

    return wp

  end

end
