using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using EmployeeWebApp.Models;

namespace EmployeeWebApp.Controllers
{
    public class EmployeeEncryptsController : Controller
    {
        private RandomEntities db = new RandomEntities();

        // GET: EmployeeEncrypts
        public ActionResult Index()
        {
            return View(db.EmployeeEncrypts.ToList());
        }

        // GET: EmployeeEncrypts/Details/5
        public ActionResult Details(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            EmployeeEncrypt employeeEncrypt = db.EmployeeEncrypts.Find(id);
            if (employeeEncrypt == null)
            {
                return HttpNotFound();
            }
            return View(employeeEncrypt);
        }

        // GET: EmployeeEncrypts/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: EmployeeEncrypts/Create
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "EmployeeID,Name,Position,Department,Address,AnnualSalary,SSN")] EmployeeEncrypt employeeEncrypt)
        {
            if (ModelState.IsValid)
            {
                db.EmployeeEncrypts.Add(employeeEncrypt);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            return View(employeeEncrypt);
        }

        // GET: EmployeeEncrypts/Edit/5
        public ActionResult Edit(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            EmployeeEncrypt employeeEncrypt = db.EmployeeEncrypts.Find(id);
            if (employeeEncrypt == null)
            {
                return HttpNotFound();
            }
            return View(employeeEncrypt);
        }

        // POST: EmployeeEncrypts/Edit/5
        // To protect from overposting attacks, please enable the specific properties you want to bind to, for 
        // more details see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "EmployeeID,Name,Position,Department,Address,AnnualSalary,SSN")] EmployeeEncrypt employeeEncrypt)
        {
            if (ModelState.IsValid)
            {
                db.spEmployeeEncryptUpdate(employeeEncrypt.EmployeeID, employeeEncrypt.Name, employeeEncrypt.Position, employeeEncrypt.Department, employeeEncrypt.Address, employeeEncrypt.AnnualSalary, employeeEncrypt.SSN);
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            return View(employeeEncrypt);
        }

        // GET: EmployeeEncrypts/Delete/5
        public ActionResult Delete(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            EmployeeEncrypt employeeEncrypt = db.EmployeeEncrypts.Find(id);
            if (employeeEncrypt == null)
            {
                return HttpNotFound();
            }
            return View(employeeEncrypt);
        }

        // POST: EmployeeEncrypts/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(int id)
        {
            EmployeeEncrypt employeeEncrypt = db.EmployeeEncrypts.Find(id);
            db.EmployeeEncrypts.Remove(employeeEncrypt);
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}
