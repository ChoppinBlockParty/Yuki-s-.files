    -- Переключение по всем окнам по комбинации Win+Tab
    awful.key({ modkey }, "Tab", function ()
        awful.menu.menu_keys.down = { "Down", "Tab" }
        local cmenu = awful.menu.clients({width=500}, {keygrabber=true, coords={x=0, y=20} })
    end),

    -- Переключение по Alt+Tab в рамках активных тегов
    awful.key({ "Mod1",           }, "Tab", function()
       local tag = awful.tag.selected()
       for i=1, #tag:clients() do
          tag:clients()[i].minimized=false end
       awful.client.focus.byidx(1) if client.focus then client.focus:raise() end end),


    -- Обратное переключение Alt+Shift+Tab в рамках активных тегов
    awful.key({ "Mod1", "Shift"          }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),


  awful.key({"Mod1"}, "Tab", function ()
    -- кнопочки
    awful.menu.menu_keys.down = { "Down", "Tab","j" }
    awful.menu.menu_keys.up = { "Up","k" }
    -- Определяем рабочее пространство
    local w_area = screen[ mouse.screen ].workarea
    local tab_menu_width = beautiful.menu_width
    --  собираем все запущеные окна со всех мониторов
    local clients_count =  0
    for s=1,screen.count() do
      clients_count = clients_count + table.getn(client.get(s))
    end
    --local x_padding = 400
    --находим центр по всем осям и совмещаем его с центром меню
    local x_padding = w_area.x+w_area.width/2-tab_menu_width/2
    local y_padding = w_area.y+w_area.height/2-clients_count*beautiful.menu_height/2
    -- рисуем меню
    local cmenu = awful.menu.clients({ width = tab_menu_width },
         {keygrabber=true, coords={x=x_padding, y=y_padding} })
  end)
