# 📋 SX_WarehouseCraft

## 🧠 About

A simple warehouse crafting script built for the **ESX Legacy Framework**. This was created for fun and shared as my first repository. It comes with a custom warehouse MLO if you don't already have one, along with an `import.sql` for logging crafts directly into your database — so you can see exactly who crafted what and when.

My favorite feature is the **crafting history tab**, where players can view their last 10 crafts. Everything you need — including install instructions — is listed below to get this resource running on your ESX server with zero problems.

---

## ⚙️ What You Need

- [oxmysql](https://github.com/overextended/oxmysql)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox-inventory](https://github.com/overextended/ox_inventory)
- [ox_target](https://github.com/overextended/ox_target)

---

## 🖥️ Install

**1.** Open the folder and drag the entire `warehouse mlo` folder into your server resources, then ensure it in your `server.cfg`.

**2.** Drag the entire `wh_craft` folder into your server resources and ensure it **after** the warehouse MLO.

```
ensure warehouse_mlo
ensure wh_craft
```

**3.** Open `import.sql` inside the `wh_craft` resource and paste the contents into a database query to create the crafting logs table.

**4.** Open the config inside the `shared` folder and tune everything to your liking.

**5.** Don't worry about the `images` folder — just boot up your server and enjoy!

---

## 🗒️ PSA

This is my first repository and I'm still getting familiar with FiveM scripting. The quality of future scripts will continue to improve, but I wanted to share this one since it's among the first scripts I've made that I'm truly proud of. Hope you enjoy it! 🙏



