/*-------------------------------------------------------------------------

    BadgerStockMarket
    Created by Badger
    
    Pages:
    #phoneSection = Whole phone
    #navigateBar = Nav bar (bottom)
    #loadingSection
    #browsePage
    #graphPage
    #dollarPage
    #userPage
-------------------------------------------------------------------------*/
function changePage(page) {
    // Change the page to the ID of page specified 
    $('#browsePage').hide();
    $('#graphPage').hide();
    $('#dollarPage').hide();
    $('#userPage').hide();
    var graphButton = $('#graphButton');
    var dollarButton = $('#dollarButton');
    var browseButton = $('#browseButton');
    var userButton = $('#userButton');
    switch (page) {
        case '#browsePage':  
            $('#browsePage').show();
            browseButton.addClass('active');
            graphButton.removeClass('active');
            dollarButton.removeClass('active');
            userButton.removeClass('active');
            $('#graphPage').hide();
            $('#dollarPage').hide();
            $('#userPage').hide(); 
            break;
        case '#graphPage':
            $('#browsePage').hide();
            $('#graphPage').show();
            browseButton.removeClass('active');
            graphButton.addClass('active');
            dollarButton.removeClass('active');
            userButton.removeClass('active');
            $('#dollarPage').hide();
            $('#userPage').hide();
            break;
        case '#dollarPage':
            $('#browsePage').hide();
            $('#graphPage').hide();
            $('#dollarPage').show();
            browseButton.removeClass('active');
            graphButton.removeClass('active');
            dollarButton.addClass('active');
            userButton.removeClass('active');
            $('#userPage').hide();
            break;
        case '#userPage':
            $('#browsePage').hide();
            $('#graphPage').hide();
            $('#dollarPage').hide();
            $('#userPage').show();
            browseButton.removeClass('active');
            graphButton.removeClass('active');
            dollarButton.removeClass('active');
            userButton.addClass('active');
            break;
    }
}
var resourceName = ""; 
var panelShown = false;
var multiplyPricesBy = 1;
var theirStockData = {};
var tagTracker = {};
var stocks = {}

$( function() {
    window.addEventListener( 'message', function( event ) {
        var item = event.data;
        if ( item.resourcename ) {
            resourceName = item.resourcename;
        }
        if (item.show) {
            // Show them the phone and shit
            $('#phoneSection').show();
            $('#loadingSection').show();
            $('#notifs').show();
            showAllCollections();
            setTimeout(function() {
                $('#loadingSection').hide(); 
                $('#graphPage').show();
            }, 4000);
        }
        if (item.stockData) {
            // This is the stock data
            var alreadyContains = [];
            $('#pStocks').empty();
            $('#pCollections').empty();
            $('#stockGraphs').empty();
            $('#stock-tabs').empty();
            $('#stock-tab-graphs').empty();
            var graphButton = $('#graphButton');
            var dollarButton = $('#dollarButton');
            var browseButton = $('#browseButton');
            var userButton = $('#userButton');
            browseButton.removeClass('active');
            graphButton.removeClass('active');
            dollarButton.removeClass('active');
            userButton.removeClass('active');
            graphButton.addClass('active');
            var counter = 0;
            var total = 0;
            for (const key in item.stockData) {
                total++;
            }
            for (const key in item.stockData) {
                counter += 1;
                //console.log("The stock is " + key);
                var stockLabel = key;
                var stockInfo = item.stockData[key];
                var stockHTML = stockInfo.data;
                var stockLink = stockInfo.link;
                var stockAbbrev = stockLink.split("symb=")[1];
                var tags = stockInfo.tags;
                // TODO: We need to parse stockHTML and get the data for it for the stock
                let doc = new DOMParser();
                var html = doc.parseFromString(stockHTML, 'text/html');
                var cost = getElementByXpath('/html/body/div[3]/div[1]/div[1]/div[2]/table/tbody/tr/td[1]/span', html).innerText;
                
                var imgURL = getElementByXpath('//*[@id="wsod_companyChart"]/img', html).src;
                imgURL = imgURL.replace('nui:', "");
                var percentChange = getElementByXpath('/html/body/div[3]/div[1]/div[1]/div[2]/table/tbody/tr/td[2]/span[4]/span', html).innerText;
                //console.log(cost);
                //console.log(imgURL);
                //console.log(percentChange);
                //console.log(stockAbbrev);
                stocks[stockAbbrev] = {cost, imgURL, stockLabel, percentChange};
                // Set up pStocks #pStocks 
                if (percentChange.includes('-')) {
                    $('#pStocks').append(
                        '<div class="pStocks-box negative" tags="' + tags + '"><span>' + stockLabel + '</span><h3>' + stockAbbrev + '</h3><h4>' + percentChange + '</h4></div>'
                        );
                } else {
                    $('#pStocks').append(
                        '<div class="pStocks-box positive" tags="' + tags + '"><span>' + stockLabel + '</span><h3>' + stockAbbrev + '</h3><h4>' + percentChange + '</h4></div>'
                        );  
                }
                // End pStocks 
                // Set up pCollections
                //console.log(tags);
                var tagArr = String(tags).split(',');
                for (const tag in tagArr) {
                    if (!alreadyContains.includes(tagArr[tag])) {
                        $('#pCollections').append('<button onclick="showCollections(\'' + tagArr[tag] + '\')">' + tagArr[tag] + '</button>');
                        alreadyContains.push(tagArr[tag]);
                    }
                }
                
                // End pCollections
                // Set up stockGraphs #stockGraphs
                $('#stockGraphs').append('<div class="item">' +
                                '<div class="item-data">' +
                                    '<h2>' + stockAbbrev + '</h2>' +
                                    '<h3>' + stockLabel + '</h3>' +
                                '</div>' + 
                                '<hr />' + 
                                '<div class="item-graph">' +
                                    '<img src="' + 'https:' + imgURL + '" width="100%" />' +
                                '</div>' +
                                '<hr />' + 
                                '<div class="item-section">' +
                                '<h3>$' + cost + ' per stock</h3>' +
                                    '<button class="buy" onclick="buyStock(\'' + stockAbbrev + '\', ' + cost + ')">Buy</button>' +
                                    '<button class="sell" onclick="sellStock(\'' + stockAbbrev + '\', ' + cost + ')">Sell</button>' +
                                '</div>' +
                            '</div>');
                // End stockGraphs
                // Set up dollarPage stock-tabs
                /**/
                if (counter == total) {
                    $('#stock-head-title').text(stockLabel);
                    $('#stock-tabs').append('<span class="active" id="' + stockAbbrev + '-tab" onclick="showStock(\''
                        + stockAbbrev + '\');">' + stockAbbrev + '</span>');
                    $('#stock-tab-graphs').append('<img id="stock-graph-' + stockAbbrev + '" width="100%" ' + 
                        'style="" src="https:' + imgURL + '" />');
                    $('#stock-tab-graphs').append('<div class="buttons" id="buttons-' + stockAbbrev + '">' +
                                '<button class="buy" onclick="buyStock(\'' + stockAbbrev + '\', ' + cost + ')">BUY</button>' +
                                '<button class="sell" onclick="sellStock(\'' + stockAbbrev + '\', ' + cost + ')">SELL</button>' +
                            '</div>');
                } else {
                    $('#stock-head-title').text(stockLabel);
                    $('#stock-tabs').append('<span id="' + stockAbbrev + '-tab" onclick="showStock(\''
                        + stockAbbrev + '\');">' + stockAbbrev + '</span>');
                    $('#stock-tab-graphs').append('<img id="stock-graph-' + stockAbbrev + '" width="100%" ' + 
                        'style="display: none;" src="https:' + imgURL + '" />');
                    $('#stock-tab-graphs').append('<div class="buttons" id="buttons-' + stockAbbrev + '" style="display: none;">' +
                                '<button class="buy" onclick="buyStock(\'' + stockAbbrev + '\', ' + cost + ')">BUY</button>' +
                                '<button class="sell" onclick="sellStock(\'' + stockAbbrev + '\', ' + cost + ')">SELL</button>' +
                            '</div>');
                }
                /**/
                // End dollarPage stock-tabs 
            }
        }
        if (item.notification) {
            // This is the max amount of stocks they're allowed to have 
            $('#notifs').prepend("" + item.notification + "");
        }
        if (item.theirStockData) {
            // This is their stock data, set it up for the user page
            $('#userData').empty();
            var stockData = Object.entries(item.theirStockData[0]);
            var keysSorted = item.theirStockData[1];
            stockData.forEach(([key, value]) => {
                var stock = value;
                var id = stock[0];
                var abbrev = stock[1];
                var prichPurch = stock[2];
                var ownCount = stock[3];
                $('#userData').append('<tr><td>' + abbrev + "</td><td>$" + prichPurch + "</td><td>" + ownCount + "</td></tr>");
            });
        }
    } );
} )

function buyStock(stockAbbrev, costPer) {
    if (sendData("BadgerStocks:Buy", {stock: stockAbbrev, cost: costPer})) {
        // It was a valid buy
    }
}
function sellStock(stockAbbrev, costPer) {
    if (sendData("BadgerStocks:Sell", {stock: stockAbbrev, cost: costPer})) {
        // It was a valid sell
    }
}
function showCollections(topic) {
    $('#pStocks').children().each(function (index) {
        var tags = $(this).attr('tags');
        if (tags.includes(topic)) {
            $(this).show();
        } else {
            $(this).hide();
        }
    });
}
function showAllCollections() {
    $('#pStocks').children().each(function (index) {
        $(this).show();
    });
}
function showStock(stockAbbrev) {
    $.each( stocks, function( key, value ) {
        var label = Object.values(value)[2]
        if (key == stockAbbrev) {
            // This is the one we want to set visible now
            $('#stock-head-title').text(label);
            $("#" + key + '-tab').addClass("active");
            $('#stock-graph-' + key).show();
            $('#buttons-' + key).show();
        } else {
            // Hide this
            $("#" + key + '-tab').removeClass("active");
            $('#stock-graph-' + key).hide();
            $('#buttons-' + key).hide();
        }
    });
}

function getElementByXpath(path, html) {
  return document.evaluate(path, html, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
}
function copyText(text) {
    var $temp = $("<input>");
    $("body").append($temp);
    $temp.val(text).select();
    document.execCommand("copy");
    $temp.remove();
}

function sendData( name, data ) {
    $.post( "http://" + resourceName + "/" + name, JSON.stringify( data ), function( datab ) {
        if ( datab != "ok" ) {
            return false;
        }            
    } );
    return true;
}
function clickHome() {
    $('#phoneSection').hide();
    $('#notifs').empty();
    $('#notifs').hide();
    sendData("BadgerPhoneClose", {close: true});
    $('#browsePage').hide();
    $('#graphPage').hide();
    $('#dollarPage').hide();
    $('#userPage').hide();
}