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
  <link rel="stylesheet" href="/roman.css"/>
  <style type="text/css">
    .t4 { font-family: triplicate, Consolas, "Liberation Mono", Menlo, Courier, monospace; }
  </style>
  <meta name="viewport" content="width=device-width, initial-scale=1">

</head>
<body>
    <article>
        <h1 class="t4">$FILENAME</h1>

        <div class="fullwidth code t4" style="white-space: pre-wrap;">$(cat $FILENAME)</div>
    </article>
</body>
</html>
EOF
