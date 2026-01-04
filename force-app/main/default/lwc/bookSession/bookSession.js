import { LightningElement, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import SPEAKER_SELECTED from '@salesforce/messageChannel/SpeakerSelected__c';
import { getRecord } from 'lightning/uiRecordApi';
import getSessionsByDate from '@salesforce/apex/SpeakerController.getSessionsByDate';
import isSpeakerAvailable from '@salesforce/apex/SpeakerController.isSpeakerAvailable';
import createAssignment from '@salesforce/apex/SpeakerController.createAssignment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = ['Speaker__c.Bio__c', 'Speaker__c.Speciality__c'];

export default class BookSession extends LightningElement {

    speakerId;
    bio;
    speciality;
    selectedDate;
    selectedSession;
    sessionOptions = [];
    disableCreate = true;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        subscribe(this.messageContext, SPEAKER_SELECTED, msg => {
            this.speakerId = msg.speakerId;
        });
    }

    @wire(getRecord, { recordId: '$speakerId', fields: FIELDS })
    wiredSpeaker({ data }) {
        if (data) {
            this.bio = data.fields.Bio__c.value;
            this.speciality = data.fields.Speciality__c.value;
        }
    }

    formatTime(ms) {
    if (ms === null || ms === undefined) {
        return '';
    }

    const totalMinutes = Math.floor(ms / 60000);
    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;

    return `${hours.toString().padStart(2, '0')}:${minutes
        .toString()
        .padStart(2, '0')}`;
}

   handleDate(e) {
    this.selectedDate = e.target.value;
    this.sessionOptions = [];
    this.selectedSession = null;
    this.disableCreate = true;

    getSessionsByDate({ sessionDate: this.selectedDate })
        .then(res => {
            console.log('Sessions returned:', JSON.stringify(res));

           this.sessionOptions = res.map(s => {
           const start = this.formatTime(s.Start_Time__c);
           const end = this.formatTime(s.End_Time__c);

    return {
        label: `${s.Name} (${start} - ${end})`,
        value: s.Id
    };
});

        })
        .catch(err => console.error(err));
}

handleSession(e) {
    this.selectedSession = e.detail.value;

    isSpeakerAvailable({
        speakerId: this.speakerId,
        sessionId: this.selectedSession
    }).then(res => {
        this.disableCreate = !res;
        if (!res) {
            this.toast('Error', 'Slot is already booked, try another date', 'error');
        }
    });
}


    createAssignment() {
        createAssignment({
            speakerId: this.speakerId,
            sessionId: this.selectedSession
        }).then(() => {
            this.toast('Success', 'Speaker assigned successfully', 'success');
            this.disableCreate = true;
            window.location.reload();
        });
    }

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
