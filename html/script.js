window.addEventListener('message', function(event) {
    if (event.data.action == 'open' || event.data.action == 'setVehicleResults') {
        $('.wrapper').fadeIn()
        const vehicles = event.data.vehicles
        $('.vehicleList').html('')
        for (let i=0; i < vehicles.length; i++) {
            $('.vehicleList').append(`
            <div class="vehicleItem">
                <div class="vehicleItemImage">
                    <img src="nui://oakyVehicleshop/html/assets/${vehicles[i].model}.jpg" alt="">
                </div>
                <div class="vehicleItemName">${vehicles[i].name}</div>
                <div class="vehicleItemPrice">${new Intl.NumberFormat("en-US", { type: "currency", currency: "USD" }).format(vehicles[i].price)}</div>
                <div class="vehicleItemButton">
                    <button class="btn btn-buy" id="buyVehicle" data-model="${vehicles[i].model}">Kaufen</button>
                </div>
            </div>
            `)
        }
    }
})

$(document).on('click', '#buyVehicle', function() {
    const model = $(this).attr('data-model')
    $.post('https://oakyVehicleshop/buyVehicle', JSON.stringify({
        model: model
    }))
})

$('#vehicleName').on('input', function() {
    const value = $(this).val()
    const category = $('#vehicleCategory').val()

    $.post('https://oakyVehicleshop/searchVehicle', JSON.stringify({
        value: value,
        category: category
    }))
})

$('#vehicleCategory').change(function() {
    const value = $('#vehicleName').val()
    const category = $('#vehicleCategory').val()

    $.post('https://oakyVehicleshop/searchVehicle', JSON.stringify({
        value: value,
        category: category
    }))
})


document.onkeyup = function (data) {
    if (data.which == 27) {
        $.post('https://oakyVehicleshop/close')
        $('.wrapper').fadeOut("slow")
    }
}