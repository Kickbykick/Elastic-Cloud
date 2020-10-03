const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { Client } = require('@elastic/elasticsearch')

admin.initializeApp(functions.config().firebase);

const env = functions.config();
const auth = {
  username: env.elasticsearch.username,
  password: env.elasticsearch.password,
};

const client = new Client({
    node: env.elasticsearch.url,
    auth: auth
})


exports.createPost = functions.firestore
    .document('Cities/{CityId}')
    .onCreate( async (snap, context) => {
        await client.index({
            index: 'locations',
            type: '_doc',
            id: snap.id,
            body: snap.data()
        })
    });

exports.updatePost = functions.firestore
    .document('Cities/{CityId}')
    .onUpdate( async (snap, context) => {
        await client.update({
            index: 'locations',
            type: '_doc',
            id: context.params.CityId,
            body: snap.after.data()
        })
    });

exports.deletePost = functions.firestore
    .document('Cities/{CityId}')
    .onDelete( snap => {
        client.delete({
            index: 'locations',
            type: '_doc',
            id: snap.id,
        })
    });