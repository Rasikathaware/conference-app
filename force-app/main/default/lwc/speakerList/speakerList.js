import { LightningElement,api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import SPEAKER_SELECTED from '@salesforce/messageChannel/SpeakerSelected__c';

export default class SpeakerList extends LightningElement {

    @api speakers;

    @wire(MessageContext)
    messageContext;
    columns =[
        { label:'Name', fieldName:'Name'},
        { label:'Email', fieldName:'Email__c'},
        { label:'Speciality', fieldName:'Speciality__c'}, 
        {
            type:'button',
            typeAttributes:{
                label:'Book Session',
                name:'book',
                variant:'brand'
            }
        }   

    ];

    handleRowAction(event)
    {
        
        const speakerId = event.detail.row.Id;


        console.log('Selected Speaker:', speakerId);

        publish(this.messageContext, SPEAKER_SELECTED, {
            speakerId: speakerId
        });
    }
}
