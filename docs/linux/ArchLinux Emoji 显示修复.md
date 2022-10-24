# ArchLinux Emoji 显示修复

在 ArchLinux 下，Emoji 往往会显示成乱码，通过修改 Fontconfig 可以解决这个问题。

首先安装 noto-fonts-emoji 字体

`sudo pacman -S noto-fonts-emoji`

然后修改 Fontconfig

```sh
sudo su
mkdir -p /etc/fonts/conf.avail
cat>/etc/fonts/conf.avail/75-noto-color-emoji.conf<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

    <!-- Add generic family. -->
    <match target="pattern">
        <test qual="any" name="family"><string>emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <!-- This adds Noto Color Emoji as a final fallback font for the default font families. -->
    <match target="pattern">
        <test name="family"><string>sans</string></test>
        <edit name="family" mode="append"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test name="family"><string>serif</string></test>
        <edit name="family" mode="append"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test name="family"><string>sans-serif</string></test>
        <edit name="family" mode="append"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test name="family"><string>monospace</string></test>
        <edit name="family" mode="append"><string>Noto Color Emoji</string></edit>
    </match>

    <!-- Block Symbola from the list of fallback fonts. -->
    <selectfont>
        <rejectfont>
            <pattern>
                <patelt name="family">
                    <string>Symbola</string>
                </patelt>
            </pattern>
        </rejectfont>
    </selectfont>

    <!-- Use Noto Color Emoji when other popular fonts are being specifically requested. -->
    <match target="pattern">
        <test qual="any" name="family"><string>Apple Color Emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Segoe UI Emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Segoe UI Symbol</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Android Emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Twitter Color Emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Twemoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Twemoji Mozilla</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>TwemojiMozilla</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>EmojiTwo</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Emoji Two</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>EmojiSymbols</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Symbola</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

</fontconfig>
EOF

ln -sf /etc/fonts/conf.avail/75-noto-color-emoji.conf /etc/fonts/conf.d/
```

然后可以前往 <https://github.com/13rac1/emojione-color-font/blob/master/full-demo.html> 测试 Emoji 是否显示正确。

## ref

<https://ld246.com/article/1581074244078>
