const userReducer = (state = {
    users: [
        {
            id : 1,
            first_name: "daniel",
            last_name: "chen",
            phone_number: 123

        },
        {
            id : 2,
            first_name: "daniel",
            last_name: "chen",
            phone_number: 456

        }


    ]

}, action)=>{
    switch (action.type){
        case "SEARCH_USERS":
            state = {
                ...state,
                users: [Array.from(action.payload)]
            };
            break;

    }
    return state;

}

module.exports = {
    userReducer,
}
