import { LightningElement, api, wire, track } from 'lwc';
import getEngagementSummary from '@salesforce/apex/EngagementSummaryController.getEngagementSummary';
import createQuickFollowUpCall from '@salesforce/apex/EngagementSummaryController.createQuickFollowUpCall';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EngagementSummary extends LightningElement {
    @api recordId;

    @track engagementName;
    @track opportunityAmount = 0;
    @track completedTasks = 0;
    @track upcomingEvents = 0;
    @track loading = true;

    @wire(getEngagementSummary, { engagementId: '$recordId' })
    wiredSummary({ error, data }) {
        this.loading = false;
        if(data) {
            this.engagementName = data.engagementName;
            this.opportunityAmount = data.opportunityAmount;
            this.completedTasks = data.completedTasks;
            this.upcomingEvents = data.upcomingEvents;
        } else if(error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    handleQuickFollowUp() {
        createQuickFollowUpCall({ engagementId: this.recordId, engagementName: this.engagementName })
            .then(() => {
                this.showToast('Success', 'Follow-up call task created', 'success');
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}


