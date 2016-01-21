#!/bin/bash

FILENAME=$1

cat << EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <title>Pollen Source: $FILENAME</title>
  <link rel="stylesheet" href="../css/tufte.css"/>
  <link rel="stylesheet" href="../css/joel.css"/>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style type="text/css">
    .sourcebox {
        padding: 1em;
        border: solid 1px #efefef;
        background: #f5fff0;
        }
  </style>
</head>
<body>
    <article>
        <h1>$FILENAME</h1>

        <div class="fullwidth code sourcebox" style="white-space: pre-wrap;">$(cat $FILENAME)</div>
    </article>
</body>
</html>
EOF
