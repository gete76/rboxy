{ has: [
    {tag: 'table' , css: 'redbox', has: [
        {tag: 'thead', has: [
            {tag: 'tr', has: [
                {tag: 'th', has: ['First Name'], click: ''},
                {tag: 'th', has: ['Last Name']} 
            ]}
        ]},
        {tag: 'tbody', bind: 'foreach: user', has: [
            {tag: 'tr',  has: [
                {tag: 'td', bind: 'text: first_name'},
                {tag: 'td', bind: 'text: last_name'}    
            ]}
        ]}
    ]},
    {tag: 'button', has: 'get more', onclick: 'getUsers()'}
]}

 
