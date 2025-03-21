==========================================
Getting Started with the BRC Algorithm
==========================================

.. note::
   The **Branch and Bound Algorithm for Reliability of Coherent Systems** (**BRC**) is an efficient method for analysing **system reliability with discrete-state component events and a binary-state system event.** It identifies (sub-)minimal survival and failure rules while computing system failure probability using a branch-and-bound approach.

Introduction
============

The BRC algorithm identifies (sub-)minimal survival and failure rules and computes the system failure probability using a branch-and-bound approach. 

BRC applies to **any general coherent system**, meaning systems where an improvement in component states never leads to a worse system state.

The figure below illustrates the BRC process (or more details, refer to the official publication on `arXiv <https://arxiv.org/abs/2410.22363>`_):

.. figure:: _static/img/brc_tutorial/brc.png
   :width: 800px
   :align: center
   :alt: BRC Algorithm

   **Illustration of the BRC algorithm.** 

Code Demonstration
==================

The Jupyter notebook for this tutorial is available on `GitHub <https://github.com/jieunbyun/MBNpy/blob/main/notebooks/tutorial_brc.ipynb>`_.

MBNPy Version
-------------
This tutorial uses **MBNPy v0.1.2**.

Installation
============

Ensure you have the required dependencies installed before running the tutorial:

.. code-block:: python

   import networkx as nx
   import matplotlib.pyplot as plt
   from mbnpy import cpm, variable, inference
   from networkx.algorithms.flow import shortest_augmenting_path
   from mbnpy import brc
   import numpy as np

Example: Five-Edge Network
==========================

Network Topology
----------------
We analyse the **five-edge network** below:

.. code-block:: python

   nodes = {'n1': (0, 0),
            'n2': (1, 1),
            'n3': (1, -1),
            'n4': (2, 0)}

   edges = {'e1': ['n1', 'n2'],
            'e2': ['n1', 'n3'],
            'e3': ['n2', 'n3'],
            'e4': ['n2', 'n4'],
            'e5': ['n3', 'n4']}

   # Plot network
   plt.figure(figsize=(4,3))
   G = nx.Graph()
   for node in nodes:
       G.add_node(node, pos=nodes[node])
   for e, pair in edges.items():
       G.add_edge(*pair, label=e)

   pos = nx.get_node_attributes(G, 'pos')
   edge_labels=nx.get_edge_attributes(G, 'label')
   nx.draw(G, pos, with_labels=True)
   nx.draw_networkx_edge_labels(G, pos, edge_labels=edge_labels)
   plt.show()

.. figure:: _static/img/brc_tutorial/network.png
   :width: 500px
   :align: center
   :alt: Network Topology

   **Network topology with five edges.**

Defining Component Events
-------------------------
The **state of each edge** is represented by a binary variable:

.. code-block:: python

   varis = {}
   for k, v in edges.items():
       varis[k] = variable.Variable(name=k, values=[0, 1])  # 0 = non-functional, 1 = functional

   print(varis['e1'])

The probabilities of each component event:

.. code-block:: python

   probs = {'e1': {0: 0.01, 1: 0.99},
            'e2': {0: 0.01, 1: 0.99},
            'e3': {0: 0.05, 1: 0.95},
            'e4': {0: 0.05, 1: 0.95},
            'e5': {0: 0.10, 1: 0.90}}

Defining the System Event
-------------------------
The system's state is determined by **connectivity** between an **origin-destination (OD) pair**.

A system function must:
- Take a **dictionary of component states** as input.
- Return:
  1. **System value** (informational).
  2. **System state** (`'s'` for survival, `'f'` for failure).
  3. **Minimum component state** that guarantees the system state.

The function is implemented as follows:

.. code-block:: python

   def net_conn(comps_st, od_pair, edges, varis):
       G = nx.Graph()
       for k, x in comps_st.items():
           G.add_edge(edges[k][0], edges[k][1])
           G[edges[k][0]][edges[k][1]]['capacity'] = varis[k].values[x]

       # Perform max-flow analysis
       G.add_edge(od_pair[1], 'new_d', capacity=1)
       f_val, f_dict = nx.maximum_flow(G, od_pair[0], 'new_d')

       if f_val > 0:
           return f_val, 's', {k: 1 for k, x in f_dict.items() if x > 0}
       else:
           return f_val, 'f', None

The OD pair is set to `('n1', 'n4')`:

.. code-block:: python

   od_pair = ('n1', 'n4')

Running the BRC Algorithm
=========================

Now, we run the BRC algorithm, ensuring that the analysis **is complete** (`pf_bnd_wr=0.0`):

.. code-block:: python

   brs, rules, sys_res, monitor = brc.run(probs, sys_fun, max_sf=np.inf, max_nb=np.inf, pf_bnd_wr=0.0)

BRC output
---------------------------

.. code-block:: text

   *** Analysis completed with 8 system function runs ***
   System failure probability: 5.16e-3
   Found non-dominated rules (failure: 4, survival: 4)

Extracting System Rules
-----------------------

To retrieve these rules, use:

.. code-block:: python

   print(rules['s'])  # Survival rules
   print(rules['f'])  # Failure rules

This returns:

.. code-block:: text

   Survival Rules: [{'e1': 1, 'e4': 1}, {'e2': 1, 'e5': 1}, {'e2': 1, 'e3': 1, 'e4': 1}, {'e1': 1, 'e3': 1, 'e5': 1}]
   Failure Rules: [{'e4': 0, 'e5': 0}, {'e1': 0, 'e2': 0}, {'e1': 0, 'e3': 0, 'e5': 0}, {'e2': 0, 'e3': 0, 'e4': 0}]

Computing Component Importance Measure
==============================

`Conditional probability-based importance measure (CPIM) <https://doi.org/10.1016/j.ress.2008.02.011>`_ is calculated as:

.. math::

   P(X_n=0 | S=0) = \frac{P(X_n=0, S=0)}{P(S=0)}

.. code-block:: python

   def get_cim(comp_name, cpms, varis, pf):
       var_elim_names = [e for e in edges if e != comp_name]
       cpm_s_x = inference.variable_elim(cpms, [varis[e] for e in var_elim_names])
       p_s0_x0 = sum(cpm_s_x.p[np.where((cpm_s_x.C == [0, 0]).all(axis=1))])
       return p_s0_x0[0] / pf

   cims = {comp: get_cim(comp, cpms, varis, 5.16e-3) for comp in edges}
   print(cims)

Results:
{'e1': 0.036, 'e2': 0.031, 'e3': 0.059, 'e4': 0.928, 'e5': 0.934}


Component importance visualisation:

.. figure:: _static/img/brc_tutorial/cims.png
   :width: 500px
   :align: center
   :alt: Component Importance

----------------------
Summary
----------------------
- The **BRC algorithm** calculates **system failure probability** for **general coherent systems**.
- It identifies **(sub-)minimal survival and failure rules**.
- Identified rules are used to decompose system event space into **failure and survival branches**.
- **Branches** can be used to compute advanced probability queries such as **component importance measures**.


