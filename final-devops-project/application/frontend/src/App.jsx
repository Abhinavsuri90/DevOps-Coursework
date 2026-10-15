import { useCallback, useEffect, useState } from "react";
import { api } from "./api.js";

const CATEGORIES = ["food", "travel", "books", "rent", "fun", "other"];
const today = () => new Date().toISOString().slice(0, 10);
const rupees = (value) =>
  Number(value).toLocaleString("en-IN", { style: "currency", currency: "INR" });

export default function App() {
  const [expenses, setExpenses] = useState([]);
  const [summary, setSummary] = useState(null);
  const [filter, setFilter] = useState("");
  const [form, setForm] = useState({ title: "", amount: "", category: "food", spent_on: today() });
  const [error, setError] = useState("");
  const [version, setVersion] = useState("");

  const refresh = useCallback(async () => {
    try {
      const [list, totals] = await Promise.all([api.list(filter), api.summary()]);
      setExpenses(list);
      setSummary(totals);
      setError("");
    } catch (err) {
      setError(`Could not reach the API: ${err.message}`);
    }
  }, [filter]);

  useEffect(() => {
    refresh();
  }, [refresh]);

  useEffect(() => {
    api.version().then((info) => setVersion(info.version)).catch(() => setVersion(""));
  }, []);

  async function addExpense(event) {
    event.preventDefault();
    try {
      await api.create({ ...form, amount: Number(form.amount).toFixed(2) });
      setForm({ ...form, title: "", amount: "" });
      refresh();
    } catch (err) {
      setError(`Could not save: ${err.message}`);
    }
  }

  async function removeExpense(id) {
    await api.remove(id);
    refresh();
  }

  const top = summary?.by_category?.[0];

  return (
    <main>
      <header>
        <h1>SpendWise</h1>
        <p>Track what you spend this semester</p>
      </header>

      {error && <div className="error">{error}</div>}

      <section className="cards">
        <div className="card">
          <span>Total spent</span>
          <strong>{summary ? rupees(summary.total) : "…"}</strong>
        </div>
        <div className="card">
          <span>Expenses</span>
          <strong>{summary ? summary.count : "…"}</strong>
        </div>
        <div className="card">
          <span>Top category</span>
          <strong>{top ? `${top.category} · ${rupees(top.total)}` : "—"}</strong>
        </div>
      </section>

      <section className="panel">
        <h2>Add an expense</h2>
        <form onSubmit={addExpense}>
          <input
            placeholder="What did you buy?"
            value={form.title}
            onChange={(e) => setForm({ ...form, title: e.target.value })}
            required
          />
          <input
            type="number"
            min="0.01"
            step="0.01"
            placeholder="Amount (₹)"
            value={form.amount}
            onChange={(e) => setForm({ ...form, amount: e.target.value })}
            required
          />
          <select value={form.category} onChange={(e) => setForm({ ...form, category: e.target.value })}>
            {CATEGORIES.map((c) => (
              <option key={c}>{c}</option>
            ))}
          </select>
          <input
            type="date"
            value={form.spent_on}
            onChange={(e) => setForm({ ...form, spent_on: e.target.value })}
            required
          />
          <button type="submit">Add</button>
        </form>
      </section>

      <section className="panel">
        <div className="panel-head">
          <h2>Expenses</h2>
          <select value={filter} onChange={(e) => setFilter(e.target.value)} aria-label="Filter by category">
            <option value="">All categories</option>
            {CATEGORIES.map((c) => (
              <option key={c}>{c}</option>
            ))}
          </select>
        </div>
        {expenses.length === 0 ? (
          <p className="empty">No expenses yet.</p>
        ) : (
          <table>
            <thead>
              <tr>
                <th>Date</th>
                <th>Title</th>
                <th>Category</th>
                <th className="num">Amount</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {expenses.map((e) => (
                <tr key={e.id}>
                  <td>{e.spent_on}</td>
                  <td>{e.title}</td>
                  <td>
                    <span className={`tag tag-${e.category}`}>{e.category}</span>
                  </td>
                  <td className="num">{rupees(e.amount)}</td>
                  <td>
                    <button className="link" onClick={() => removeExpense(e.id)} aria-label={`Delete ${e.title}`}>
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
      <footer>
        SpendWise · final DevOps project · Abhinav (24BCS10282)
        {version && <span className="version"> · version {version}</span>}
      </footer>
    </main>
  );
}
