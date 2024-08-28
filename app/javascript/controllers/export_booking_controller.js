import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['status'];

  connect() {} ;

  export(event) {
    event.preventDefault();

    const params = window.location.search;
    const currentUrl = window.location.origin + "/user/booking_fields/export" + params ;
    fetch(currentUrl, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
        method: 'GET'
      })
      .then(response => response.json())
      .then(data => {
        if (data.jid) {
          const jobId = data.jid;
          this.statusTarget.textContent = I18n.t('job.export.begin_export');
          this.timer = setInterval(() => {
          this.checkJobStatus(jobId)
            }, 800);
          }
        })
        .catch(error => console.error(error));
  }

  checkJobStatus(jobId) {
    const exportStatusUrl = `${window.location.origin}/user/booking_fields/export_status?job_id=${jobId}`;
    fetch(exportStatusUrl, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      method: 'GET'
    })
    .then(response => response.json())
    .then(data => {
      if (data) {
        const percentage = data.percentage;
        this.statusTarget.textContent = I18n.t('export.percent', {percent: percentage}) ;
        if(data.status === "error") {
          this.stopCheckJobStatus();
        }
        else if (data.status === "complete") {
          this.statusTarget.textContent = I18n.t('job.export.success');
          this.stopCheckJobStatus()
          const downloadUrl = `${window.location.origin}/user/booking_fields/export_download.xlsx?job_id=${jobId}`;
          window.location.href = downloadUrl;
          this.statusTarget.textContent = '';
        }
      }
    })
    .catch(error => console.error(error));
  }

  stopCheckJobStatus() {
    if(this.timer) {
      clearInterval(this.timer);
    }
  }

  disconnect() {
    this.stopCheckJobStatus();
  }
}
