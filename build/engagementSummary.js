import { LightningElement, api, wire } from 'lwc';
import getSummaryData from '@salesforce/apex/EngagementSummaryController.getSummaryData';
import createFollowUpTask from '@salesforce/apex/EngagementSummaryController.createFollowUpTask';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EngagementSummary extends LightningElement {

    @api recordId;
    summary = {};

    @wire(getSummaryData, { engagementId: '$recordId' })
    wiredSummary({ data, error }) {
        if (data) {
            this.summary = data;
        } else if (error) {
            console.error(error);
        }
    }

    async handleCreateTask() {
        try {
            await createFollowUpTask({ engagementId: this.recordId });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Follow-up call task created',
                    variant: 'success'
                })
            );
        } catch (error) {
            console.error(error);
        }
    }
}
