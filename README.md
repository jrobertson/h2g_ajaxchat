# Introducing the H2G Ajax Chat gem

    require 'h2g_ajaxchat'


    ac = AjaxChat.new(ChatCore.new)

    req1 = DummyRequest.new
    ac.req(req1).index
    ac.req(req1).login_post 'Jim'
    # logs in with username 'Jim'

    req2 = DummyRequest.new
    ac.req(req2).index
    ac.req(req2).login_post 'Bob'
    # logs in with username 'Bob'

    ac.req(req1).chatter
    s  = ac.req(req1).chatter('hello')


    puts ac.req(req2).chatter
    ac.req(req2).chatter 'anybody here?'
    puts ac.req(req1).chatter


The above example can copied pasted into an IRB session to observe the chat conversation between 2 users. The DummyRequest object is a RACK session object substitute and is used to store the username and the identifier of the last message read.

Here we can see user *Jim* logs in, and then user *Bob* logs in. Then *Jim* says *hello*, and *Bob* replies with the message *anybody here?*

The method *chatter() is used to both display messages and send messages.

## Resources

* h2g_ajaxchat https://rubygems.org/gems/h2g_ajaxchat

chat gem ajax h2gajaxchat rack
