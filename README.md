# BadgerStockMarket
A FiveM Script (that actually utilizes the real stock market, pretty nifty)

## For all your hosting needs:
![Iceline Hosting](https://i.gyazo.com/24c65c27acc53ce0656cda7e7ed29230.gif)

### Use code `BADGER15` at https://iceline-hosting.com/billing/aff.php?aff=284 for `15% off` your first month of any service (excluding dedicated servers)

## Jared's Developer Community [Discord]
[![Developer Discord](https://discordapp.com/api/guilds/597445834153525298/widget.png?style=banner4)](https://discord.com/invite/WjB5VFz)

## What is it?
BadgerStockMarket is a stock market that is based on the real stock market! The prices and graphs actually come from the real stock market! I wanted to make a nifty script to interact with the stock market and actually invest it, but without investing real money. You can do that with this script! You use ESX money in-game to invest into the stock market. The stock market updates/refreshes every time you open the phone, so this updates in real live time. Make sure you sell your stocks when you are making money, not when you are losing money!
## Commands
`/stocks` - Opens up the phone menu for the stocks
## Screenshots
![Running /stocks](https://i.gyazo.com/94e8d2d10607ebb211e579f08878cd0f.gif)

![Purchasing Stocks](https://i.gyazo.com/246c95870ce2724afab536fec21f8221.gif)

![Selling Stocks on another page](https://i.gyazo.com/a14d4afda42421d2865bbe3cfc0a5764.gif)

![Browsing Page](https://i.gyazo.com/515771f3f8f6ee85b8c1b63f5abe9fe3.gif)

![All pages and turning off the phone](https://i.gyazo.com/15738ab69ea833af91f8eafbe16cdfe0.gif)

## Configuration
```
Config = {
	maxStocksOwned = {
		['BadgerStockMarket.Stocks.Normal'] = 20,
		['BadgerStockMarket.Stocks.Bronze'] = 100,
		['BadgerStockMarket.Stocks.Silver'] = 500,
		['BadgerStockMarket.Stocks.Gold'] = 99999999999999999999999999999999999999999999
	},
	stocks = {
		['Apple Stock'] = {
			link = 'https://money.cnn.com/quote/quote.html?symb=AAPL',
			tags = {'Technology', 'Software'}
		},
		['Citigroup Stock'] = {
			link = 'https://money.cnn.com/quote/quote.html?symb=C',
			tags = {'Bank'}
		},
		['General Electric Stock'] = {
			link = 'https://money.cnn.com/quote/quote.html?symb=GE',
			tags = {'Automobiles', 'Vehicles', 'Cars'}
		}
	}
}
```
You must use https://money.cnn.com website for this to work properly (for each Stock). Add as many stocks as you would like :)

`'BadgerStockMarket.Stocks.Normal'` is the permission node (ACE permission node) that a player has to have to have that many stocks. You can set up multiple different permission nodes and allow a certain number of stocks for different groups of people. Maybe donators get more stocks?

## Liability Reasons
For liability reasons, I wanted to include this at the bottom. BadgerStockMarket is in no way affiliated with the Stock Market and/or its proprieters. BadgerStockMarket was created as an educational tool to be used within the GTA V modification known as FiveM. BadgerStockMarket is also not affiliated with the Robinhood application. Although the script used the Robinhood logo. Once again, BadgerStockMarket was created as an educational tool. If anyone has a problem with this, please contact me and we can get the changes adjusted appropriately, thank you.

## Download

https://github.com/JaredScar/BadgerStockMarket
