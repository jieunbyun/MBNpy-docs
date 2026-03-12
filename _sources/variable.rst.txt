variable
========

Class
-----

.. py:class:: Variable(name: str, values: list = [], B_flag: str = 'auto')
   :noindex:

   A class to manage information about a variable.

   :param name: Name of the variable. This is just for identification purposes and does not affect analysis results.
   :type name: str
   :param values: Description of basic states. The corresponding location of each state in the list is used as the state index. When applicable, use an ordering where lower indices represent worse outcomes, as some modules assume this ordering. For example: ``['failure', 'survival']`` since ``0 < 1``.
   :type values: list
   :param B_flag: Flag to determine how B is generated. Options are:

                  - 'store': the mapping matrix is generated and stored.
                  - 'fly': the mapping matrix is generated on the fly during inference.
                  - 'auto': the mapping matrix is generated and stored if the number of basic states is less than or equal to 6; otherwise, it is generated on the fly.

                  Since the number of states increases exponentially with the number of basic states, it is recommended to use 'auto' or 'fly' for large numbers of basic states.
   :type B_flag: str

Example Usage
-------------

.. code-block:: python

   from mbnpy.variable import Variable

   # Define basic states
   basic_states = ['failure', 'survival']

   # Create a Variable instance
   var = Variable(name='Outcome', values=basic_states)

   # Generate the mapping matrix
   mapping_matrix = var.gen_B()
   print(f"Mapping Matrix: {mapping_matrix}")

   # Get state index from a set of basic states
   state_index = var.get_state({1})
   print(f"State Index for {{1}}: {state_index}")

   # Get set of basic states from a state index
   state_set = var.get_set(0)
   print(f"State Set for index 0: {state_set}")

   # Get state index from a binary vector
   state_index_from_vector = var.get_state_from_vector([0, 1])
   print(f"State Index from vector [0, 1]: {state_index}")

Output:

::

   Mapping Matrix: [{0}, {1}, {0, 1}]
   State Index for {1}: 1
   State Set for index 0: {0}
   State Index from vector [0, 1]: 1

Methods
-------

gen_B
~~~~~

.. py:method:: Variable.gen_B()
   :noindex:

   Generates the mapping matrix.

   :return: Mapping matrix.
   :rtype: list of sets

update_B
~~~~~~~~

.. py:method:: Variable.update_B()
   :noindex:

   Updates the mapping matrix based on current values and B_flag. To be used when the values or B_flag are updated.

   **Example:**

   .. code-block:: python

      basic_states = ['failure', 'survival', 'improved']
      var.values = basic_states
      var.update_B()
      print(var)

   **Output:**

   ::

      Variable(name='Survival',
               values=['failure', 'survival', 'improved'],
               B=[{0}, {1}, {2}, {0, 1}, {0, 2}, {1, 2}, {0, 1, 2}])

get_state
~~~~~~~~~

.. py:method:: Variable.get_state(state_set: set)
   :noindex:

   Finds the state index of a given set of basic states.

   :param state_set: Set of basic states.
   :type state_set: set
   :return: State index in B matrix of the given set.
   :rtype: int

   **Example:**

   .. code-block:: python

      state_index = var.get_state({0, 1})
      print(state_index)

   **Output:**

   ::

      3

get_set
~~~~~~~

.. py:method:: Variable.get_set(state: int)
   :noindex:

   Finds the set of basic states represented by a given state index.

   :param state: State index.
   :type state: int
   :return: Set of basic states.
   :rtype: set

   **Example:**

   .. code-block:: python

      state_set = var.get_set(3)
      print(state_set)

   **Output:**

   ::

      {0, 1}

get_state_from_vector
~~~~~~~~~~~~~~~~~~~~~

.. py:method:: Variable.get_state_from_vector(vector: list)
   :noindex:

   Finds the state index for a given binary vector.

   :param vector: Binary vector. 1 if the basic state is involved, 0 otherwise.
   :type vector: list
   :return: State index.
   :rtype: int
   :raises ValueError: If the vector is not the same length as the number of basic states.

   **Example:**

   .. code-block:: python

      state_index_from_vector = var.get_state_from_vector([1, 1, 0])
      print(state_index_from_vector)

   **Output:**

   ::

      3
