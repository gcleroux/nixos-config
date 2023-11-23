{ lib, ... }: {
  xdg.mimeApps = {
    enable = true;
    defaultApplications = let
      # take from the respective mimetype files
      images = [
        "image/bmp"
        "image/gif"
        "image/jpeg"
        "image/jpg"
        "image/pjpeg"
        "image/png"
        "image/tiff"
        "image/x-bmp"
        "image/x-gray"
        "image/x-icb"
        "image/x-ico"
        "image/x-png"
        "image/x-portable-anymap"
        "image/x-portable-bitmap"
        "image/x-portable-graymap"
        "image/x-portable-pixmap"
        "image/x-xbitmap"
        "image/x-xpixmap"
        "image/x-pcx"
        "image/svg+xml"
        "image/svg+xml-compressed"
        "image/vnd.wap.wbmp;image/x-icns"
      ];
      urls = [
        "text/html"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/about"
        "x-scheme-handler/unknown"
      ];
      documents = [
        "application/vnd.comicbook-rar"
        "application/vnd.comicbook+zip"
        "application/x-cb7"
        "application/x-cbr"
        "application/x-cbt"
        "application/x-cbz"
        "application/x-ext-cb7"
        "application/x-ext-cbr"
        "application/x-ext-cbt"
        "application/x-ext-cbz"
        "application/x-ext-djv"
        "application/x-ext-djvu"
        "image/vnd.djvu+multipage"
        "application/x-bzdvi"
        "application/x-dvi"
        "application/x-ext-dvi"
        "application/x-gzdvi"
        "application/pdf"
        "application/x-bzpdf"
        "application/x-ext-pdf"
        "application/x-gzpdf"
        "application/x-xzpdf"
        "application/postscript"
        "application/x-bzpostscript"
        "application/x-gzpostscript"
        "application/x-ext-eps"
        "application/x-ext-ps"
        "image/x-bzeps"
        "image/x-eps"
        "image/x-gzeps"
        "image/tiff"
        "application/oxps"
        "application/vnd.ms-xpsdocument"
        "application/illustrator"
      ];
      audioVideo = [
        "application/ogg"
        "application/x-ogg"
        "application/mxf"
        "application/sdp"
        "application/smil"
        "application/x-smil"
        "application/streamingmedia"
        "application/x-streamingmedia"
        "application/vnd.rn-realmedia"
        "application/vnd.rn-realmedia-vbr"
        "audio/aac"
        "audio/x-aac"
        "audio/vnd.dolby.heaac.1"
        "audio/vnd.dolby.heaac.2"
        "audio/aiff"
        "audio/x-aiff"
        "audio/m4a"
        "audio/x-m4a"
        "application/x-extension-m4a"
        "audio/mp1"
        "audio/x-mp1"
        "audio/mp2"
        "audio/x-mp2"
        "audio/mp3"
        "audio/x-mp3"
        "audio/mpeg"
        "audio/mpeg2"
        "audio/mpeg3"
        "audio/mpegurl"
        "audio/x-mpegurl"
        "audio/mpg"
        "audio/x-mpg"
        "audio/rn-mpeg"
        "audio/musepack"
        "audio/x-musepack"
        "audio/ogg"
        "audio/scpls"
        "audio/x-scpls"
        "audio/vnd.rn-realaudio"
        "audio/wav"
        "audio/x-pn-wav"
        "audio/x-pn-windows-pcm"
        "audio/x-realaudio"
        "audio/x-pn-realaudio"
        "audio/x-ms-wma"
        "audio/x-pls"
        "audio/x-wav"
        "video/mpeg"
        "video/x-mpeg2"
        "video/x-mpeg3"
        "video/mp4v-es"
        "video/x-m4v"
        "video/mp4"
        "application/x-extension-mp4"
        "video/divx"
        "video/vnd.divx"
        "video/msvideo"
        "video/x-msvideo"
        "video/ogg"
        "video/quicktime"
        "video/vnd.rn-realvideo"
        "video/x-ms-afs"
        "video/x-ms-asf"
        "audio/x-ms-asf"
        "application/vnd.ms-asf"
        "video/x-ms-wmv"
        "video/x-ms-wmx"
        "video/x-ms-wvxvideo"
        "video/x-avi"
        "video/avi"
        "video/x-flic"
        "video/fli"
        "video/x-flc"
        "video/flv"
        "video/x-flv"
        "video/x-theora"
        "video/x-theora+ogg"
        "video/x-matroska"
        "video/mkv"
        "audio/x-matroska"
        "application/x-matroska"
        "video/webm"
        "audio/webm"
        "audio/vorbis"
        "audio/x-vorbis"
        "audio/x-vorbis+ogg"
        "video/x-ogm"
        "video/x-ogm+ogg"
        "application/x-ogm"
        "application/x-ogm-audio"
        "application/x-ogm-video"
        "application/x-shorten"
        "audio/x-shorten"
        "audio/x-ape"
        "audio/x-wavpack"
        "audio/x-tta"
        "audio/AMR"
        "audio/ac3"
        "audio/eac3"
        "audio/amr-wb"
        "video/mp2t"
        "audio/flac"
        "audio/mp4"
        "application/x-mpegurl"
        "video/vnd.mpegurl"
        "application/vnd.apple.mpegurl"
        "audio/x-pn-au"
        "video/3gp"
        "video/3gpp"
        "video/3gpp2"
        "audio/3gpp"
        "audio/3gpp2"
        "video/dv"
        "audio/dv"
        "audio/opus"
        "audio/vnd.dts"
        "audio/vnd.dts.hd"
        "audio/x-adpcm"
        "application/x-cue"
        "audio/m3u"
      ];

      code = [
        "text/english"
        "text/plain"
        "text/x-log"
        "text/x-go"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
    in (lib.genAttrs code (_: [ "nvim.desktop" ]))
    // (lib.genAttrs images (_: [ "imv.desktop" ]))
    // (lib.genAttrs urls (_: [ "chromium-browser.desktop" ]))
    // (lib.genAttrs documents (_: [ "org.pwmt.zathura.desktop" ]))
    // (lib.genAttrs audioVideo (_: [ "vlc.desktop" ])) // (lib.genAttrs [
      "x-scheme-handler/sgnl"
      "x-scheme-handler/signalcaptcha"
    ] (_: [ "signal-desktop.desktop" ]));
  };
}