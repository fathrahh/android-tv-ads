var htmlTemplate = (String videoId) => """
  <!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Document</title>
    <style>
      html,body {
        margin: 0;
        padding: 0;
      }
      .container{
        width: 100vw;
        height: 100vh;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <iframe
        width="100%"
        height="100%"
        src="https://www.youtube.com/embed/$videoId"
        title="YouTube video player"
        frameborder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
      ></iframe>
    </div>
  </body>
</html>
""";
