# Migrating from KMail to an IMAP server

## Scenario

This note describes how to migrate a KMail mailbox in Maildir format to
an IMAP server based e-mail solution. In this article we will use the Dovecot
IMAP server which focus on security and IMAP standard compliancy. The procedure
to use other IMAP servers are similar but might have subtle difference in
directory and file structure on the IMAP server side.

## Setting the scenario: Why IMAP what is IMAP?

Today it is not uncommon that one person own several computers, one might have
one stationary high performance computer at home or office and a smaller
laptop (or laptops) to bring along while traveling or otherwise moving about. 
In addition most modern mobile phones are powerful enough to run a mail client
so that might be thought of as one additional computer.

The problem is now how to keep all these mail clients in sync, i.e. how can
you make sure that you will see the exact same mailbox on each client?

Today, with the still most common method to fetch and download your 
mail to the mail client being POP3 (Post Office Protocol) it is simply not 
practically doable.

(Note: As the astute reader will comment it is technically possible to keep
the mail on the POP3 server - but that has major limitations as will be described
below.)

The logical solution to this problem is to keep your mailbox in one
central place and use a suitable client to view that mailbox from whatever
device you happen to be on for the moment. In the most simplistic view this is
what IMAP (Internet Message Access Protocol) was designed to allow you to do.

So how is this different from using POP3 and just keep all the messages on
the server? There are both deep technical and practical differnces in advantage
of the IMAP protocol. The most obvious from a user perspective is that it allows
you to keep a mail directory structure on the server that is viewable on all
clients and that you don't have to download any mails locally in order to be 
able to read it.

With POP3 you cannot view what is on the server, you can only download mail from
one inbox and store it locally. This means that in order to read and see mail they
must always be downloaded locally to your client first. Not so with the IMAP protocol.
WIth IMAP it is possible to always keep the mails just on the server and then
view them (and directory structure) on the client. 

This becomes really important with thin clients
(think mobile phones and sub-size laptops) growing in popularity. For example, my
mailbox, has a total size of ~6GB, spanning back some 12 year of mails,
which wouldn't really be possible to download on a mobile phone (not to mention the cost!)
just to be able to find the reply you sent 2 years ago to that friend of yours.

In addition the IMAP protocol allows you to keep track on what mails are new, what mails
you have replied to, what mails you have read etc. So once you have read a mail on
your mobile phone connected to your IMAP server you will see this mail as read even
on your stationary desktop computer as well as any other devices you connect to your
IMAP server.

So why setting up a IMAP server at all at home when there is ISPs (or GMail) that
already have that done for you? The reasons might wary.

* If you, like me, have moved around a lot and had to change ISP you do not 
want to constantly be in the trouble of having to pay (if it is at all possible) 
the ISP to export/import a lot of old mail from/to there IMAP server.

* Some ISP still doesn't support IMAP

* You might have several accounts and you want to get the mail from all these
accounts into one central mail repository.

* Most ISP will not allow you "unlimited" mailbox size so it is simply
not possible to keep all your mail on the server. For example, my current 
main ISP only allows 25MB of mail storage which could be as little as 5-6 mail with
attachments. A far cry from my current ~6GB of mail storage.

* Safety. Personally my mails are vital. I would not want to rely on someone else
to properly backup and take care of my mail.

* Longevity, in todays business world there is simply no guarantee that your ISP
(or even GMail) will last forever. If your ISP does a chapter 11 the chances of you
getting back your mail from there servers are probably very slim. However, as long
as you take care of your own server (with proper multiple backups!) it will last forever!

* Advanced mail processing. In my case I have clients that can request services via
specially formatted mail and my server will automatically initiate a number of actions. 
This means running extra processing software together with my IMAP server (procmail et.al)
in order to service those requests.

Of course, if you only have one main email account and that 
you are happy to keep your mail on, say GMail, and access that through IMAP
then you should do so.


## Understanding how mails are stored

Before going into details about installing and setting up the Dovecot server
it is critical to understand how mail is stored. The first thing to know is that
in the world of Unix there is two major ways that has emerged as the as the most
common ways for how both mail servers and most clients store there mail.

The first (and oldest) way is to keep all mails from a certain mail directory
in one single large file. Thjis is usucally referred to as the "mbox" format.
Basically all your mails (for each mailfolder) are concatenated as text files
into one large file. The mail client (or server) then maintains one or several
indexes to know where in that large file certain mails can be found.

The second way is pretty much the opposite of the "mbox" method. Here all mails
are stored as individual files. This format is referred to as the "maildir"
format. Again, the client or the server maintains one or several indexes in order
to be able to keep track of the mails.

The discussion on which methods is the best to use is a hot topic and has been
for a long time and we want go into this heated discussion one here. 
Bottom line is that both ways have there advantages as well as problems (not much help here). 
However, most newer installation of both clients and servers usually have set the
default to be using the "maildir" format. 
This is also the format KMail internally stores local mails in.

In the above discussions we have mentioned that several index files are used to keep
track of all the mails and make it faster to find and store new mails. 
Unfortunately there is no standard in how this should be done so it is not as 
simple as just copying the whole file structure from one mail server/client to 
the next and expect
it to work since all use different internal format for these indexes. The good news
here is that most clients (and servers) have a very robust design. This means that
when they can't find any indexes for a specific mail folder they simply re-creates
them from the existing mails. 

Apart from taking some time there is now other inherent drawback. This then gives us the
first clue on how to move mails. Just move all the mail files and ignore the indexes.
They will be re-created in the new client/server that receives all the mails.

We should also mention that there are other mail servers who use propritary formats 
in order to avoid some
of the inherent problems with, for example, maildir. Some servers goes as far as to invent
there own file system specially designed to be effective for mail handling. 

In the rest of this article we will however only focus on the maildir format.

### Maildir format and file names in detail

As mentioned above when the maildir format is used then all mails are stored as 
individual files and then we hit some practical problems. For once all the file
names in a mail folder must be absolutely unique. In order to guarantee this most
servers and clients (for example KMail) use very long gibberish looking files names
made up of several parts. One common method is to use some hash for the curernmt server
and folder together with a unique serial number that is increased by one for each
new mail in a folder. So for example two typical name of files that contains a single
mail could be

```txt
js3419dfh62231we.330456_2:,RS
js3419dfh62231we.330457_2:,U
```

The ending two letters have a special meaning. As we briefly mentioned above an IMAP
server is able to keep track on which mail should be marked as read, replied to, unread
etc. One first idea would be to store these flags in some of the index files, but as
also mentioned above this would be very risky in case one of the index files got corruped
since there is no way to otherwise restore these flags. So instead these flags are
stored as part part of the filename by adding a postfix which is a combination of single
letters which indicate the state of the mail. The most important letters used as flags on
the mail have the following meaning

```txt
P R S T D F
    * Flag "P" (passed): the user has resent/forwarded/bounced this message to someone else.
    * Flag "R" (replied): the user has replied to this message.
    * Flag "S" (seen): the user has viewed this message, though perhaps he didn't read all the way through it.
    * Flag "T" (trashed): the user has moved this message to the trash; the trash will be emptied by a later user action.
    * Flag "D" (draft): the user considers this message a draft; toggled at user discretion.
    * Flag "F" (flagged): user-defined flag; toggled at user discretion. 
    
S             = Seen, i.e. the mail has been read
R             = Replied, i.e. the mail has been replied to
U             = Unseen, i.e. the user nows the mail is there but haven't read it
```

So now we have solved the problem with the individual filenames. One could then be tempted
to beleive that it would suffice to just creata directory (which represents the 
mail directory) and the store all the files in there together with the index and
yes, in principle that wouldn't be a completely dumb way to do it. However, in order
to increase the robustness this is not qiute the way it si done. Remember that we are
dealing with network issues here and we need to gurantee that we either download a 
correct mail or no mail at all. We cannot risk have half mails due to the fact that
somenoe pulled the network cable in the wrong moment. So the maildir format uses a 
(just) slightly more complicated way to ensure atomiciy when a new mail arrives.
In order to achieve this when the mail comes in it is first written to a temporary folder
and when the entire mail has been downloaded correct it is then moved over to the real
mailfolder. This way reduces the risk that we get a incomplete mail in our real mail
folder. Now we almost have the maildrit structure. Howver, the designes of maildir wanted 
the format to be efficient in quickly understanding what mails are new and haven't yet been
seen by the user. So in order to achieve this they decided that all new mail that have just
arrived should be stored in a separate folder, adequately named "new". So now we are ready
to understand the maildir format.

The maildir format uses three directories in each mail folder

```txt
tmp         = Where new mails are written while being downloaded
new         = Where new mails can be found after they ahve been fully downlaoded
cur         = (Current) Where all mails that are not new is stored.
```

So in a typical mail folder directory the "tmp" directory should always be empty.
the "new" directory having just a few mails or being empty and finally the "cur" 
directory having a (possible huge) number of files.

In addition to these three directories the index files are also stored in the mail
folder. The names of these will differ depending on the client or server.

So, let's just recaptulate what we have gone through. We now understand how each mail
is stored in a single file and how the name of that file is created. We also know that
the mails are most likely in a directory called "cur" in the mail folder.

It is now time to uderstand the overall directory structure. 

Back in the beginning of mail (cirka 1983) people had one inbox where all mails
were stored. Fine if you have only have 100 mail all in all but soon people started
to wanting to have a structure in there 1000's of mails and mailfolders were "
invented" in order to sort all the mails. On the server each mail folder is mapped
towards a separate directory using a specail naming convention. This naming convention
is different between different mail clients and servers but they all have in common that
the mail folder name you see in your client can be found somewhere in the directory name.

In addition servers now a days support the concept of mail folders in mailfolders nesting
arbitrary deep (however most people seem to find 3 levels as the conceptual limit for
mail folders within folders to be useful).

So we will now look in detail for a typical structure using the Dovecot default
naming convention. We will assume that the user name is "adam". The most basic
structure on the Doevcot server would be

```txt
adam
    inbox
                   tmp
                   new
                   cur
```

This is all the server needs to handle incoming mails. This is basically the one
single inbox you get by default. However, all mail clients also creates at least
two subfolders, one to store all sent mails in and one to sue as a "trash can".
Please note that these are treated as any other folders by the server and is in
no way "special" folders. The exact naming convetion is entirely controlled by
the mail client and in some cases by the user. For example in Thunderbird
mail client you can select the name of the folder youw ant to store all sent mails
in. So let's now look at the minimum practical mail server directory after a mail
client have connected the first time to the server and automatically told the server
to add these directories

```txt
adam
    inbox
                   tmp
                   new
                   cur
                   .sent-mail
                             tmp
                             new
                             cur
                   .Trash
                             tmp
                             new
                             cur
```

Again, this directory structure is the way the Dovecot server does it. As you can see
the mail folder directories are created under the inbox top folder 
and they are also "hidden" directories, meaning they start there name with a dot ".".

So, if the above is the minimum practical directory structure a real user would probably
have a hierarchy of perdsonal folders, for example, one folder to store all newsletters
in and perhaps one folder to to keep the best of all the "friday-afternnon-joke-mails" that
he receives.

If he creates two more directories from his mail client he might end up with the following
structure.


```txt
adam
    inbox
                   tmp
                   new
                   cur
                   .sent-mail
                             tmp
                             new
                             cur
                   .Trash
                             tmp
                             new
                             cur
                   .newsletters
                             tmp
                             new
                             cur
                   .fun
                             tmp
                             new
                             cur
```


# References

http://networking.ringofsaturn.com/Protocols/imap.php

